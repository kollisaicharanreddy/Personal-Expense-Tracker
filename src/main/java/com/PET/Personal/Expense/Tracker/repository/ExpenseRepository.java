package com.PET.Personal.Expense.Tracker.repository;

import com.PET.Personal.Expense.Tracker.model.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense,Long> {
    List<Expense> findByCategoryId(Long id);
}
