package com.codenameb.model.authentication;

import com.codenameb.dto.GameStartParameterDto;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SocketToken {

  @JsonProperty("action")
  private String action;

  @JsonProperty("token")
  private String token;

  @JsonProperty("gameStartParameters")
  private GameStartParameterDto gameStartParameters;

  @JsonProperty("fromUser")
  private String fromUser;

  @JsonProperty("toUser")
  private String toUser;

  @JsonProperty private String response;
}
