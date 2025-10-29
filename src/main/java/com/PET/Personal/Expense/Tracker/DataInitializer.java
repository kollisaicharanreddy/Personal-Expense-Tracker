package com.PET.Personal.Expense.Tracker;

import com.PET.Personal.Expense.Tracker.model.Category;
import com.PET.Personal.Expense.Tracker.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {
    private final CategoryRepository categoryRepository;

    @Autowired
    public DataInitializer(CategoryRepository categoryRepository){
        this.categoryRepository = categoryRepository;
    }
    @Override
    public void run(String... args){
        if(categoryRepository.count()==0) {
            System.out.println("No category found");


            Category bills = new Category();
            bills.setName("Bills");
            Category food = new Category();
            food.setName("Food");
            Category travel = new Category();
            travel.setName("Travel");
            Category utilities = new Category();
            utilities.setName("Home & Utilities");
            Category shopping = new Category();
            shopping.setName("Shopping");
            Category entertainment = new Category();
            entertainment.setName("Entertainment");

            List<Category> categories = Arrays.asList(bills, food, travel, utilities, shopping, entertainment);
            categoryRepository.saveAll(categories);

            System.out.println("All Categories Saved");
        }
        else{
            System.out.println("Category already exists");
        }
    }

}
