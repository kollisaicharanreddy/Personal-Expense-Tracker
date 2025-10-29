package com.PET.Personal.Expense.Tracker.model;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Entity
@Data
public class Expense {
    // public Long getId() {
    //     return id;
    // }

    // public void setId(Long id) {
    //     this.id = id;
    // }

    // public String getDescription() {
    //     return description;
    // }

    // public void setDescription(String description) {
    //     this.description = description;
    // }

    // public Double getAmount() {
    //     return amount;
    // }

    // public void setAmount(Double amount) {
    //     this.amount = amount;
    // }

    // public LocalDate getDate() {
    //     return date;
    // }

    // public void setDate(LocalDate date) {
    //     this.date = date;
    // }

    // public Category getCategory() {
    //     return category;
    // }

    // public void setCategory(Category category) {
    //     this.category = category;
    // }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String description;
    private Double amount;
    private LocalDate date;

    @ManyToOne
    @JoinColumn(name="category_id", nullable=false)
    private Category category;

    @Override
    public String toString() {
        // This version prevents the infinite loop by safely printing the category's name.
        return "Expense{" +
                "id=" + id +
                ", description='" + description + '\'' +
                ", amount=" + amount +
                ", date=" + date +
                ", category=" + (category != null ? category.getName() : "null") +
                '}';
    }
}
