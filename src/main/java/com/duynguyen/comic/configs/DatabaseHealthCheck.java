package com.duynguyen.comic.configs;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

@Configuration
@Slf4j
@RequiredArgsConstructor
public class DatabaseHealthCheck {
    private final DataSource masterDataSource;
    private final DataSource slaveDataSource;

    @PostConstruct
    public void checkDatabaseConnection() {
        try (Connection conn = masterDataSource.getConnection()) {
            log.info("Master Database connected successfully");
            log.info("Database Product: {}", conn.getMetaData().getDatabaseProductName());
            log.info("Database Version: {}", conn.getMetaData().getDatabaseProductVersion());
        } catch (SQLException e) {
            log.error("Failed to connect to Master database", e);
        }

        try (Connection conn = slaveDataSource.getConnection()) {
            log.info("Slave Database connected successfully");
            log.info("Database Product: {}", conn.getMetaData().getDatabaseProductName());
            log.info("Database Version: {}", conn.getMetaData().getDatabaseProductVersion());
        } catch (SQLException e) {
            log.error("Failed to connect to Slave database", e);
        }
    }
}
