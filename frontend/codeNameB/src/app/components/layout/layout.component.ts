import { NavigationService } from '../../services/navigation.service';
import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [RouterModule, RouterModule, CommonModule],
  templateUrl: './layout.component.html',
  styleUrl: './layout.component.scss',
})
export class LayoutComponent {
  constructor(
    private router: Router,
    private navigationService: NavigationService
  ) {}

  select(link: string): void {
    this.router.navigate([link]);
  }
}
