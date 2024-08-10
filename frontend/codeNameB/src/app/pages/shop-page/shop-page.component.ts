import { UtilsService } from '../../services/utils.service';
import { CommonModule } from '@angular/common';
import { ShopItem } from '../../models/ShopItem';
import { ItemService } from '../../services/item.service';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { UserService } from '../../services/user.service';
import { User } from '../../models/User';
import { Inventory } from '../../models/Inventory';
import { ERROR_TIME } from '../../static/SnackBarValues';

@Component({
  selector: 'app-shop-page',
  standalone: true,
  imports: [CommonModule, FormsModule, MatIconModule],
  templateUrl: './shop-page.component.html',
  styleUrl: './shop-page.component.scss'
})
export class ShopPageComponent {

  private items: ShopItem[] = [];
  public characters: ShopItem[] = [];
  public weapons: ShopItem[] = [];
  public stats: ShopItem[] = [];
  public userInventory: Inventory = new Inventory(0, 0, []);

  constructor(
    private itemService: ItemService,
    private userService: UserService,
    private utilityService: UtilsService
  ) {}

  async ngOnInit(): Promise<void> {
    this.userService.getCurrentUser().subscribe({
      next: (currentUser: User) => {
        this.userInventory = currentUser.inventory;
      }
    });

    this.itemService.getAllShopItems().subscribe({
      next: (shopItems: ShopItem[]) => {
        this.items = shopItems;
        this.updateItemLists();
      }
    });
  }

  private updateItemLists(): void {
    this.items.forEach((item: ShopItem) => {
      if(item.itemType == "ITEM_PLAYER") {
        if(!this.containsItem(this.characters, item)) {
          this.characters.push(item);
        }
      } else if(item.itemType == "ITEM_WEAPON") {
        if(!this.containsItem(this.weapons, item)) {
          this.weapons.push(item);
        }
      } else if(item.itemType == "ITEM_STAT") {
        if(!this.containsItem(this.stats, item)) {
          this.stats.push(item);
        }
      }
    });
  }

  private containsItem(items: ShopItem[], item: ShopItem): boolean {
    return items.filter((shopItem: ShopItem) => shopItem.id == item.id).length > 0;
  }

  public buyItem(item: ShopItem): void {
    if(this.calculatePrice(item) > this.userInventory.credits) {
      this.utilityService.openSnackbar("Sie haben nicht genug B-Coins!", "warning", 3000);
      return;
    }

    this.itemService.buyShopItem(item)?.subscribe({
      next: (nextInventory: Inventory) => {
        this.userInventory.credits -= item.price;
        this.userInventory = nextInventory;
        this.updateItemLists();
        this.utilityService.openSnackbar('Vielen Dank für Ihren Einkauf!');
      },
      error: () => {
        this.utilityService.openSnackbar('Hoppla! Da ist was schiefgelaufen :(', 'error', ERROR_TIME);
      }
    });
  }

  public itemIsAvailable(itemId: number): boolean {
    return this.userInventory.items.filter((item: ShopItem) => {
      const itemCount: number = this.getAmountOfItems(item.id);
      if(item.id == itemId && itemCount >= item.maxBuyCount) {
        return true;
      }
      return false;
    }).length <= 0;
  }

  public getAmountOfItems(itemId: number): number {
    return this.userInventory.items.filter((item: ShopItem) => {
      return itemId == item.id;
    }).length;
  }

  public calcBuyPercentage(itemId: number, max: number): number {
    const bought: number = this.getAmountOfItems(itemId);
    return Math.floor(bought / (max / 100));
  }

  public calculatePrice(item: ShopItem): number {
    const amount = this.getAmountOfItems(item.id);
    if(amount == 0) {
      return item.price;
    }
    return Math.floor(amount * item.price * 2.5);
  }

  public itemIsProgressable(item: ShopItem): boolean {
    return item.maxBuyCount > 1;
  }
}
