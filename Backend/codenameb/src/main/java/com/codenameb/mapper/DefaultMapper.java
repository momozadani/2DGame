package com.codenameb.mapper;

import com.codenameb.dto.DifficultyDto;
import com.codenameb.dto.MapDto;
import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface DefaultMapper {
    DifficultyDto toDifficultyDto(Difficulty difficulty);
    MapDto toMapDto(Map map);

    Difficulty toDifficulty(DifficultyDto difficultyDto);
    Map toMap(MapDto mapDto);

    List<MapDto> toMapDtos(List<Map> maps);
    List<DifficultyDto> toDifficultyDtos(List<Difficulty> difficulties);

}
