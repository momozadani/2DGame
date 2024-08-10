package com.codenameb.dto;

import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import com.codenameb.model.inventory.ShopItem;
import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GameStartParameterDto {
  private String gameState;
  private ShopItem character;
  private Map map;
  private Difficulty difficulty;
  private List<ShopItem> items;
}
