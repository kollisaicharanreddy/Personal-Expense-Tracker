package com.PET.Personal.Expense.Tracker.service;

import com.PET.Personal.Expense.Tracker.model.Expense;
import com.PET.Personal.Expense.Tracker.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ExpenseService {

        private final ExpenseRepository expenseRepository;

        @Autowired
        public ExpenseService(ExpenseRepository expenseRepository){
            this.expenseRepository = expenseRepository;
        }

        public List<Expense> getAll(){
            return expenseRepository.findAll();
        }
        public Optional<Expense> getById(Long id){
            return expenseRepository.findById(id);
        }
        public Expense createExpense(Expense expense){
            return expenseRepository.save(expense);
        }

        public boolean deleteById(Long id){
            if(expenseRepository.existsById(id)){
                expenseRepository.deleteById(id);
                return true;
            }
            return false;
        }
    public List<Expense> getExpensesByCategoryId(Long categoryId) {
        return expenseRepository.findByCategoryId(categoryId);
    }
    public Optional<Expense> updateExpense(Long id, Expense expenseDetails) {
        return expenseRepository.findById(id).map(existingExpense -> {
            existingExpense.setDescription(expenseDetails.getDescription());
            existingExpense.setAmount(expenseDetails.getAmount());
            existingExpense.setDate(expenseDetails.getDate());
            existingExpense.setCategory(expenseDetails.getCategory());
            return expenseRepository.save(existingExpense);
        });
    }
}

