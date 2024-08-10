package com.codenameb.controller;

import com.codenameb.dto.GetUserDto;
import com.codenameb.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    @GetMapping("/current")
    public ResponseEntity<GetUserDto> getCurrentUserByAuthentication() {
        GetUserDto user = this.userService.getUserByAuthentication();
        return ResponseEntity.ok(user);
    }

    @GetMapping("/{id}")
    public ResponseEntity<GetUserDto> getUserById(@PathVariable Long id) {
        GetUserDto userDto = this.userService.getUserById(id);
        return ResponseEntity.ok(userDto);
    }

    @GetMapping
    public ResponseEntity<List<GetUserDto>> getAllUsers() {
        List<GetUserDto> users = this.userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
}
