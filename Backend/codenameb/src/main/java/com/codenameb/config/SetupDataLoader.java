package com.codenameb.config;

import com.codenameb.dto.DifficultyDto;
import com.codenameb.dto.InitialDataJsonDto;
import com.codenameb.dto.MapDto;
import com.codenameb.dto.ShopItemDto;
import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import com.codenameb.model.inventory.Inventory;
import com.codenameb.model.inventory.ItemType;
import com.codenameb.model.authentication.Role;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.model.User;
import com.codenameb.repository.DifficultyRepository;
import com.codenameb.repository.ItemRepository;
import com.codenameb.repository.MapRepository;
import com.codenameb.repository.UserRepository;
import com.codenameb.service.InventoryService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class SetupDataLoader implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ItemRepository itemRepository;
    private final MapRepository mapRepository;
    private final DifficultyRepository difficultyRepository;
    private final PasswordEncoder passwordEncoder;
    private final ObjectMapper objectMapper;

    @Value("${setup.data.email}")
    private String setupEmail;
    @Value("${setup.data.password}")
    private String setupPassword;
    @Value("${setup.data.firstname}")
    private String setupFirstname;
    @Value("${setup.data.lastname}")
    private String setupLastname;
    @Value("${setup.data.credits}")
    private int setupCredits;
    @Value("classpath:setup-data.json")
    private Resource resource;

    private InitialDataJsonDto loadInitialData() throws IOException {
        return this.objectMapper.readValue(this.resource.getFile(), InitialDataJsonDto.class);
    }

    private void createDefaultItems() {
        // Delete old defaults
        this.itemRepository.deleteAll();
        this.mapRepository.deleteAll();
        this.difficultyRepository.deleteAll();


        InitialDataJsonDto initialDataJsonDto;
        try {
            initialDataJsonDto = this.loadInitialData();
        } catch(Exception e) {
            System.out.println("Error: " + e.getMessage());
            return;
        }

        // Save items
        List<ShopItemDto> items = initialDataJsonDto.getItems();
        if(items != null && !items.isEmpty()) {
            for(ShopItemDto dto : items) {
                ShopItem item = ShopItem.builder()
                        .name(dto.getName())
                        .identifier(dto.getIdentifier())
                        .description(dto.getDescription())
                        .price(dto.getPrice())
                        .imageName(dto.getImageName())
                        .itemType(dto.getItemType())
                        .maxBuyCount(dto.getMaxBuyCount())
                        .build();
                itemRepository.save(item);
            }
        }


        // Save Maps
        List<MapDto> maps = initialDataJsonDto.getMaps();
        if(maps != null && !maps.isEmpty()) {
            for(MapDto dto : maps) {
                Map map = Map.builder()
                        .name(dto.getName())
                        .identifier(dto.getIdentifier())
                        .imageName(dto.getImageName())
                        .build();
                this.mapRepository.save(map);
            }
        }


        // Save Difficulties
        List<DifficultyDto> difficulties = initialDataJsonDto.getDifficulties();
        if(difficulties != null && !difficulties.isEmpty()) {
            for(DifficultyDto dto : difficulties) {
                Difficulty difficulty = Difficulty.builder()
                        .name(dto.getName())
                        .identifier(dto.getIdentifier())
                        .build();
                this.difficultyRepository.save(difficulty);
            }
        }
    }

    private void createDefaultUserIfNotFound() {
        if (userRepository.findByEmail(setupEmail).isPresent()) {
            return;
        }
        User user = User.builder()
                        .firstname(setupFirstname)
                        .lastname(setupLastname)
                        .email(setupEmail)
                        .password(passwordEncoder.encode(setupPassword))
                        .inventory(
                                Inventory.builder()
                                    .credits(this.setupCredits)
                                    .items(this.itemRepository.findAll())
                                    .build()
                        )
                        .role(Role.ADMIN)
                        .build();
        user.getInventory().setUser(user);
        userRepository.save(user);
    }

    @Override
    public void run(String... args) {
        // Load Items
        this.createDefaultItems();

        // Create Default User
        this.createDefaultUserIfNotFound();
    }
}
