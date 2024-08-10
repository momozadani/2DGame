package com.codenameb.model.game;

import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
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
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class GameStartParameters {
  @Id @GeneratedValue private Long id;
  private GameState gameState;

  @OneToOne private ShopItem character;

  @OneToOne private Map map;

  @OneToOne private Difficulty difficulty;

  @OneToMany private List<ShopItem> items;

  @JsonIgnore
  @OneToOne(mappedBy = "gameStartParameters")
  private Game game;
}
