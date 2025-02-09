package com.duynguyen.comic.models;

import jakarta.persistence.*;

@Entity
@Table(name = "`Tags`")
public class Tag {
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    private Long id;
    private String name;
    private String description;
    private String slug;
}
