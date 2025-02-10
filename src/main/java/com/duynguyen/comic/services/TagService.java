package com.duynguyen.comic.services;

import com.duynguyen.comic.models.Tag;
import com.duynguyen.comic.repositories.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class TagService {
    private final TagRepository tagRepository;
    public List<Tag> findAll() {
        return tagRepository.findAll();
    }

    @Transactional(readOnly = false)
    public void addTag(Tag tag) {
        tagRepository.save(tag);
    }
}
