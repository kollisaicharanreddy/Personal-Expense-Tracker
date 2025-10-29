package com.PET.Personal.Expense.Tracker.repository;

import com.PET.Personal.Expense.Tracker.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepository extends JpaRepository<Category,Long> {

}
