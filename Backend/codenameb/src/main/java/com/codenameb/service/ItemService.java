package com.codenameb.service;

import com.codenameb.dto.GetInventoryDto;
import com.codenameb.dto.ShopItemDto;
import com.codenameb.exception.AuditorNotFoundException;
import com.codenameb.exception.NotAbleToBuyException;
import com.codenameb.mapper.InventoryMapper;
import com.codenameb.mapper.ItemMapper;
import com.codenameb.model.User;
import com.codenameb.model.inventory.Inventory;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.repository.InventoryRespository;
import com.codenameb.repository.ItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ItemService {
    private final ItemRepository itemRepository;
    private final InventoryRespository inventoryRespository;
    private final InventoryService inventoryService;
    private final ItemMapper itemMapper;
    private final InventoryMapper inventoryMapper;

    public List<ShopItem> getAllItems() {
        return this.itemRepository.findAll();
    }

    public GetInventoryDto buyShopItem(ShopItemDto itemToBuy) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            throw new AuditorNotFoundException("Der aktuelle Auditor konnte leider nicht gefunden werden!");
        }

        User userPrincipal = (User) authentication.getPrincipal();
        GetInventoryDto currentInventory = this.inventoryService.getInventoryByUserId(userPrincipal.getId());
        List<ShopItemDto> currentInventoryItems = currentInventory.getItems();

        if(!this.isAbleToBuy(itemToBuy, currentInventoryItems, currentInventory.getCredits())) {
            throw new NotAbleToBuyException(itemToBuy.getId());
        }
        currentInventoryItems.add(itemToBuy);
        int currentCredits = currentInventory.getCredits();
        currentCredits -= this.calculatePrice(itemToBuy, currentInventoryItems);
        currentInventory.setCredits(currentCredits);
        currentInventory.setItems(currentInventoryItems);
        Inventory savedInventory = this.inventoryRespository.save(this.inventoryMapper.toInventory(currentInventory));
        return this.inventoryMapper.toGetInventoryDto(savedInventory);
    }

    private boolean isAbleToBuy(ShopItemDto itemToBuy, List<ShopItemDto> currentInventoryItems, int availableCredits) {
        for(ShopItemDto boughtItem : currentInventoryItems) {
            if(availableCredits >= this.calculatePrice(itemToBuy, currentInventoryItems)) {
                if(boughtItem.getId().equals(itemToBuy.getId()) && itemToBuy.getMaxBuyCount() > this.getItemAmount(itemToBuy.getId(), currentInventoryItems)) {
                    return true;
                }
            } else {
                return false;
            }
        }
        return false;
    }

    private int getItemAmount(Long id, List<ShopItemDto> items) {
        int amount = 0;
        for(ShopItemDto item : items) {
            if(id.equals(item.getId())) {
                amount += 1;
            }
        }
        return amount;
    }

    private Long calculatePrice(ShopItemDto shopItemDto, List<ShopItemDto> items) {
        int itemAmount = this.getItemAmount(shopItemDto.getId(), items);
        if(itemAmount == 0) {
            return shopItemDto.getPrice();
        }
        return (long) Math.floor(itemAmount * shopItemDto.getPrice() * 2.5);
    }
}
