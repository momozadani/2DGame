import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Router } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';
import { ERROR_TIME, SUCCESS_TIME, WARNING_TIME } from '../../static/SnackBarValues';
import { UtilsService } from '../../services/utils.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
})
export class LoginComponent {
  loginForm = new FormGroup({
    email: new FormControl('', [Validators.required, Validators.email]),
    password: new FormControl('', [Validators.min(8), Validators.required]),
  });
  constructor(
    private apiService: ApiService,
    private authService: AuthService,
    private router: Router,
    private utilityService: UtilsService
  ) {}

  onSubmitForm() {

    if(!this.loginForm.valid) {
      this.utilityService.openSnackbar("Ihre Anmeldedaten sind nicht korrekt!", "warning", WARNING_TIME);
      return;
    }

    const userDetails = this.loginForm.value;
      this.apiService.loginUser(userDetails).subscribe({
        next: (response) => {
          this.authService.setAuthentication({
            access_token: response.access_token,
            refresh_token: response.refresh_token,
          });
          this.router.navigate(['/game']).then(() => {
            this.utilityService.openSnackbar("Sie wurden erfolgreich eingeloggt!", "success", SUCCESS_TIME);
          });
        },
        error: (error) => {
          this.utilityService.openSnackbar("Hoppla! Da ist etwas schief gelaufen! Bitte überprüfen Sie ihre Internetverbindung oder kontaktieren Sie den Website-Betreiber.", "error", ERROR_TIME);
        },
      });
  }
}
