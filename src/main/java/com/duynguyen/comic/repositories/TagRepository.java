package com.duynguyen.comic.repositories;

import com.duynguyen.comic.models.Tag;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TagRepository extends JpaRepository<Tag, Long> {

}
