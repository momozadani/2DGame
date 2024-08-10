package com.codenameb.repository;

import com.codenameb.model.inventory.ShopItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ItemRepository extends JpaRepository<ShopItem, Long> {
    Optional<ShopItem> findByName(String name);
    Optional<ShopItem> findByIdentifier(String identifier);
}
