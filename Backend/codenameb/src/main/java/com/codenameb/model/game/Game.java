package com.codenameb.model.game;

import com.codenameb.model.User;
import com.codenameb.model.inventory.ShopItem;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Game {
  @Id @GeneratedValue private Long id;
  private boolean win;
  private int defeatedEnemies;
  private int surviveTime;
  private int levelReached;
  private int difficulty;
  private int gold;
  private GameState gameState;

  @OneToOne(cascade = CascadeType.ALL)
  @JoinColumn(name = "game_start_parameters_id", referencedColumnName = "id")
  private GameStartParameters gameStartParameters;

  @ManyToMany(fetch = FetchType.EAGER)
  @JoinTable(
      name = "game_items",
      joinColumns = {@JoinColumn(name = "game_id")},
      inverseJoinColumns = {@JoinColumn(name = "shop_item_id")})
  List<ShopItem> itemsUsed;

  @ManyToOne
  @JoinColumn(name = "user_id", nullable = false)
  @JsonIgnore
  private User user;
}
