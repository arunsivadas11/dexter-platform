package com.dexter.platform.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MeResponse {
    private String id;
    private String name;
    private String email;
    private List<String> products;
}
