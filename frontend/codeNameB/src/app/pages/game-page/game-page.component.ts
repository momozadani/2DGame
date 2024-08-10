import { CommonModule } from '@angular/common';
import { Component, ElementRef, ViewChild } from '@angular/core';
import { SelectionComponent } from '../../components/selection/selection.component';
import { WebsocketService } from '../../services/websocket.service';
import { GameStartParameters } from '../../models/GameStartParameters';

@Component({
  selector: 'app-gamepage',
  standalone: true,
  imports: [CommonModule, SelectionComponent],
  templateUrl: './game-page.component.html',
  styleUrl: './game-page.component.scss',
})
export class GamepageComponent {

  @ViewChild('godotIframe')
  public iframe?: ElementRef;
  public isReadyState: boolean = false;
  public waitForWebsocket: boolean = true;

  constructor(
    private websocketService: WebsocketService
  ) {
    this.websocketService.doneLoading.subscribe({
      next: (done: boolean) => {
        this.waitForWebsocket = !done;
      }
    });
  }

  ngAfterViewInit(): void {
    if(!this.websocketService.initial) {
      console.log("Now reloading godot!");
      this.websocketService.reloadGodotSession();
    }
  }

  public openFullscreen(): void {
    this.iframe?.nativeElement.requestFullscreen();
  }

  public setStartParameters(parameters: GameStartParameters): void {
    this.websocketService.setGameStartParams(parameters);
    this.websocketService.postGame();
    this.isReadyState = true;
  }
}
