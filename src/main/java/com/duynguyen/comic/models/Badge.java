package com.duynguyen.comic.models;

import com.duynguyen.comic.enums.BadgeTypes;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "badges")
public class Badge {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String description;
    @Column(name = "icon_url")
    private String iconUrl;

    @Column(name = "effect_class")
    private String effectClass;
    private BadgeTypes type;
    private String requirements;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
