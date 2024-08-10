import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { RegisterComponent } from './components/register/register.component';
import { LandingpageComponent } from './pages/landing-page/landing-page.component';
import { AuthGuard } from './security/auth.guard';
import { LoginComponent } from './components/login/login.component';
import { LayoutComponent } from './components/layout/layout.component';
import { GamepageComponent } from './pages/game-page/game-page.component';
import { ShopPageComponent } from './pages/shop-page/shop-page.component';
import { ForgotPasswordComponent } from './components/forgot-password/forgot-password.component';
import { ResetPasswordComponent } from './components/reset-password/reset-password.component';

export const titlePrefix: string = "CodenameB | ";
const webRoutes: Routes = [
  { path: '', component: LandingpageComponent, title: titlePrefix.concat('Willkommen') },
  { path: 'login', component: LoginComponent, title: titlePrefix.concat('Login') },
  { path: 'register', component: RegisterComponent, title: titlePrefix.concat('Registrierung') },
  { path: 'forgot-password', component: ForgotPasswordComponent, title: titlePrefix.concat('Passwort vergessen')},
  { path: 'reset-password', component: ResetPasswordComponent, title: titlePrefix.concat('Passwort zurücksetzen')},
];

const gameRoutes: Routes = [
  {
    path: 'game',
    component: LayoutComponent,
    title: titlePrefix.concat('Spielbereich'),
    canActivate: [AuthGuard],
    canActivateChild: [AuthGuard],
    children: [
      { path: 'codenameb', component: GamepageComponent, title: titlePrefix.concat('Spiel') },
      { path: 'shop', component: ShopPageComponent, title: titlePrefix.concat('Shop') }
    ],
  }
];

export const routes: Routes = [...webRoutes, ...gameRoutes];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
