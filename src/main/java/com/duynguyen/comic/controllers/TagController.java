package com.duynguyen.comic.controllers;

import com.duynguyen.comic.models.Tag;
import com.duynguyen.comic.services.TagService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping(value = "/tags")

public class TagController {
    private final TagService tagService;

    @GetMapping(value = "/all")
    public List<Tag> getAllTags() {
        return tagService.findAll();
    }
    @PostMapping(value = "/add")
    public void addTag() {
        tagService.addTag(null);
    }
}
