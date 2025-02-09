package com.duynguyen.comic.controllers;

import com.duynguyen.comic.models.Tag;
import com.duynguyen.comic.services.TagService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@RestController
@RequestMapping(value = "/tags")
@io.swagger.v3.oas.annotations.tags.Tag(name = "Tag Controller", description = "APIs for managing tags")
public class TagController {
    private final TagService tagService;

    @GetMapping(value = "/all")
    public List<Tag> getAllTags() {
        return tagService.findAll();
    }
    @PostMapping(value = "/add")
    public void addTag(@RequestBody Tag tag) {
        tagService.addTag(tag);
    }
}
