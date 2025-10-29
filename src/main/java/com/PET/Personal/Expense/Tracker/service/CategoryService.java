package com.PET.Personal.Expense.Tracker.service;

import com.PET.Personal.Expense.Tracker.model.Category;
import com.PET.Personal.Expense.Tracker.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {
    private final CategoryRepository categoryRepository;

    @Autowired
    public CategoryService(CategoryRepository categoryRepository){
        this.categoryRepository = categoryRepository;
    }

    public List<Category> getAll(){
        return categoryRepository.findAll();
    }
    public Category create(Category category){
        return categoryRepository.save(category);
    }
}
