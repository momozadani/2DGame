package com.codenameb.repository;

import com.codenameb.model.authentication.Token;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface TokenRepository extends JpaRepository<Token, Long> {

  @Query(
      "SELECT t FROM Token t WHERE t.user.id = :userId AND t.expired = false AND t.revoked = false")
  List<Token> findAllValidTokenByUser(Long userId);

  Optional<Token> findByToken(String token);
}
