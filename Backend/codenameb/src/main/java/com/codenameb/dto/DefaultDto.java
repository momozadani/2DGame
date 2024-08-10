package com.codenameb.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class DefaultDto {
    private List<MapDto> maps;
    private List<DifficultyDto> difficulties;
}
