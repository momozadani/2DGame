import { Inventory } from "./Inventory";

export class User {
  constructor(
    public firstname: string,
    public lastname: string,
    public email: string,
    public inventory: Inventory,
    public role: string
  ) {}
}
