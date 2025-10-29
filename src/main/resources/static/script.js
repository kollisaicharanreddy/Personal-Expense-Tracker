// API Configuration
const API_BASE_URL = '/api';

// Global variables
let categories = [];
let expenses = [];
let currentEditingExpenseId = null;

// DOM Elements
const loadingSpinner = document.getElementById('loadingSpinner');
const toast = document.getElementById('toast');

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

// Initialize the application
async function initializeApp() {
    setupEventListeners();
    setupTabNavigation();
    await loadCategories();
    await loadExpenses();
    setupDateDefaults();
    updateDashboard();
}

// Setup event listeners
function setupEventListeners() {
    // Expense form submission
    document.getElementById('expenseForm').addEventListener('submit', handleExpenseSubmit);
    
    // Category form submission
    document.getElementById('categoryForm').addEventListener('submit', handleCategorySubmit);
    
    // Edit expense form submission
    document.getElementById('editExpenseForm').addEventListener('submit', handleEditExpenseSubmit);
    
    // Add category button
    document.getElementById('addCategoryBtn').addEventListener('click', openCategoryModal);
    
    // Modal close buttons
    document.getElementById('closeCategoryModal').addEventListener('click', closeCategoryModal);
    document.getElementById('closeEditModal').addEventListener('click', closeEditModal);
    document.getElementById('cancelCategory').addEventListener('click', closeCategoryModal);
    document.getElementById('cancelEdit').addEventListener('click', closeEditModal);
    
    // Filter listeners
    document.getElementById('categoryFilter').addEventListener('change', filterExpenses);
    document.getElementById('monthFilter').addEventListener('change', filterExpenses);
    
    // Close modals when clicking outside
    window.addEventListener('click', function(e) {
        const categoryModal = document.getElementById('categoryModal');
        const editModal = document.getElementById('editExpenseModal');
        
        if (e.target === categoryModal) {
            closeCategoryModal();
        }
        if (e.target === editModal) {
            closeEditModal();
        }
    });
}

// Setup tab navigation
function setupTabNavigation() {
    const navButtons = document.querySelectorAll('.nav-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    navButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Remove active class from all buttons and tabs
            navButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(tab => tab.classList.remove('active'));
            
            // Add active class to clicked button and corresponding tab
            this.classList.add('active');
            document.getElementById(targetTab).classList.add('active');
        });
    });
}

// Setup date defaults
function setupDateDefaults() {
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('date').value = today;
    document.getElementById('monthFilter').value = today.substring(0, 7);
}

// Show loading spinner
function showLoading() {
    loadingSpinner.style.display = 'flex';
}

// Hide loading spinner
function hideLoading() {
    loadingSpinner.style.display = 'none';
}

// Show toast notification
function showToast(message, type = 'success') {
    toast.textContent = message;
    toast.className = `toast show ${type}`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

// Load categories from API
async function loadCategories() {
    try {
        showLoading();
        const response = await fetch(`${API_BASE_URL}/categories`);
        
        if (!response.ok) {
            throw new Error('Failed to load categories');
        }
        
        categories = await response.json();
        populateCategorySelects();
        displayCategories();
        
    } catch (error) {
        console.error('Error loading categories:', error);
        showToast('Error loading categories: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Populate category select dropdowns
function populateCategorySelects() {
    const categorySelect = document.getElementById('category');
    const editCategorySelect = document.getElementById('editCategory');
    const categoryFilter = document.getElementById('categoryFilter');
    
    // Clear existing options (except the first default option)
    [categorySelect, editCategorySelect].forEach(select => {
        while (select.children.length > 1) {
            select.removeChild(select.lastChild);
        }
    });
    
    while (categoryFilter.children.length > 1) {
        categoryFilter.removeChild(categoryFilter.lastChild);
    }
    
    // Add category options
    categories.forEach(category => {
        [categorySelect, editCategorySelect, categoryFilter].forEach(select => {
            const option = document.createElement('option');
            option.value = category.id;
            option.textContent = category.name;
            select.appendChild(option);
        });
    });
}

// Display categories in the categories tab
function displayCategories() {
    const categoriesList = document.getElementById('categoriesList');
    categoriesList.innerHTML = '';
    
    if (categories.length === 0) {
        categoriesList.innerHTML = '<p class="empty-state">No categories found. Add your first category!</p>';
        return;
    }
    
    categories.forEach(category => {
        const categoryElement = document.createElement('div');
        categoryElement.className = 'category-item';
        categoryElement.innerHTML = `
            <div class="category-info">
                <h4>${category.name}</h4>
                <p>${getCategoryExpenseCount(category.id)} expenses</p>
            </div>
            <div class="category-actions">
                <button class="btn btn-danger btn-sm" onclick="deleteCategory(${category.id})">Delete</button>
            </div>
        `;
        categoriesList.appendChild(categoryElement);
    });
}

// Get expense count for a category
function getCategoryExpenseCount(categoryId) {
    return expenses.filter(expense => expense.category && expense.category.id === categoryId).length;
}

// Load expenses from API
async function loadExpenses() {
    try {
        showLoading();
        const response = await fetch(`${API_BASE_URL}/expenses`);
        
        if (!response.ok) {
            throw new Error('Failed to load expenses');
        }
        
        expenses = await response.json();
        displayExpenses();
        updateDashboard();
        
    } catch (error) {
        console.error('Error loading expenses:', error);
        showToast('Error loading expenses: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Display expenses
function displayExpenses() {
    const expensesList = document.getElementById('expensesList');
    const filteredExpenses = getFilteredExpenses();
    
    expensesList.innerHTML = '';
    
    if (filteredExpenses.length === 0) {
        expensesList.innerHTML = '<p class="empty-state">No expenses found.</p>';
        return;
    }
    
    filteredExpenses.forEach(expense => {
        const expenseElement = document.createElement('div');
        expenseElement.className = 'expense-item';
        expenseElement.innerHTML = `
            <div class="expense-info">
                <h4>${expense.description}</h4>
                <p>${formatDate(expense.date)} • ${expense.category ? expense.category.name : 'No Category'}</p>
            </div>
            <div class="expense-actions">
                <span class="expense-amount">$${expense.amount.toFixed(2)}</span>
                <button class="btn btn-secondary btn-sm" onclick="editExpense(${expense.id})">Edit</button>
                <button class="btn btn-danger btn-sm" onclick="deleteExpense(${expense.id})">Delete</button>
            </div>
        `;
        expensesList.appendChild(expenseElement);
    });
}

// Get filtered expenses
function getFilteredExpenses() {
    let filtered = [...expenses];
    
    const categoryFilter = document.getElementById('categoryFilter').value;
    const monthFilter = document.getElementById('monthFilter').value;
    
    if (categoryFilter) {
        filtered = filtered.filter(expense => 
            expense.category && expense.category.id == categoryFilter
        );
    }
    
    if (monthFilter) {
        filtered = filtered.filter(expense => 
            expense.date.startsWith(monthFilter)
        );
    }
    
    return filtered.sort((a, b) => new Date(b.date) - new Date(a.date));
}

// Update dashboard
function updateDashboard() {
    updateTotalExpenses();
    updateMonthlyExpenses();
    updateRecentExpenses();
    updateCategoryChart();
}

// Update total expenses
function updateTotalExpenses() {
    const total = expenses.reduce((sum, expense) => sum + expense.amount, 0);
    document.getElementById('totalExpenses').textContent = `$${total.toFixed(2)}`;
}

// Update monthly expenses
function updateMonthlyExpenses() {
    const currentMonth = new Date().toISOString().substring(0, 7);
    const monthlyTotal = expenses
        .filter(expense => expense.date.startsWith(currentMonth))
        .reduce((sum, expense) => sum + expense.amount, 0);
    
    document.getElementById('monthlyExpenses').textContent = `$${monthlyTotal.toFixed(2)}`;
}

// Update recent expenses
function updateRecentExpenses() {
    const recentExpensesContainer = document.getElementById('recentExpenses');
    const recentExpenses = expenses
        .sort((a, b) => new Date(b.date) - new Date(a.date))
        .slice(0, 5);
    
    recentExpensesContainer.innerHTML = '';
    
    if (recentExpenses.length === 0) {
        recentExpensesContainer.innerHTML = '<p class="empty-state">No recent expenses</p>';
        return;
    }
    
    recentExpenses.forEach(expense => {
        const expenseElement = document.createElement('div');
        expenseElement.className = 'recent-expense-item';
        expenseElement.innerHTML = `
            <div class="expense-details">
                <span class="expense-desc">${expense.description}</span>
                <span class="expense-category">${expense.category ? expense.category.name : 'No Category'}</span>
            </div>
            <span class="expense-amount">$${expense.amount.toFixed(2)}</span>
        `;
        recentExpensesContainer.appendChild(expenseElement);
    });
}

// Update category chart (simple text-based for now)
function updateCategoryChart() {
    const categoryChart = document.getElementById('categoryChart');
    const categoryTotals = {};
    
    expenses.forEach(expense => {
        if (expense.category) {
            const categoryName = expense.category.name;
            categoryTotals[categoryName] = (categoryTotals[categoryName] || 0) + expense.amount;
        }
    });
    
    categoryChart.innerHTML = '';
    
    if (Object.keys(categoryTotals).length === 0) {
        categoryChart.innerHTML = '<p class="empty-state">No category data available</p>';
        return;
    }
    
    Object.entries(categoryTotals)
        .sort(([,a], [,b]) => b - a)
        .forEach(([category, total]) => {
            const categoryItem = document.createElement('div');
            categoryItem.className = 'category-chart-item';
            categoryItem.innerHTML = `
                <span class="category-name">${category}</span>
                <span class="category-total">$${total.toFixed(2)}</span>
            `;
            categoryChart.appendChild(categoryItem);
        });
}

// Handle expense form submission
async function handleExpenseSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const expense = {
        description: formData.get('description'),
        amount: parseFloat(formData.get('amount')),
        date: formData.get('date'),
        category: { id: parseInt(formData.get('category')) }
    };
    
    try {
        showLoading();
        const response = await fetch(`${API_BASE_URL}/expenses`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(expense)
        });
        
        if (!response.ok) {
            throw new Error('Failed to add expense');
        }
        
        showToast('Expense added successfully!');
        e.target.reset();
        setupDateDefaults();
        await loadExpenses();
        
    } catch (error) {
        console.error('Error adding expense:', error);
        showToast('Error adding expense: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Handle category form submission
async function handleCategorySubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const category = {
        name: formData.get('categoryName')
    };
    
    try {
        showLoading();
        const response = await fetch(`${API_BASE_URL}/categories`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(category)
        });
        
        if (!response.ok) {
            throw new Error('Failed to add category');
        }
        
        showToast('Category added successfully!');
        closeCategoryModal();
        await loadCategories();
        
    } catch (error) {
        console.error('Error adding category:', error);
        showToast('Error adding category: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Handle edit expense form submission
async function handleEditExpenseSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const expense = {
        id: currentEditingExpenseId,
        description: formData.get('description'),
        amount: parseFloat(formData.get('amount')),
        date: formData.get('date'),
        category: { id: parseInt(formData.get('category')) }
    };
    
    try {
        showLoading();
        const response = await fetch(`${API_BASE_URL}/expenses/${currentEditingExpenseId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(expense)
        });
        
        if (!response.ok) {
            throw new Error('Failed to update expense');
        }
        
        showToast('Expense updated successfully!');
        closeEditModal();
        await loadExpenses();
        
    } catch (error) {
        console.error('Error updating expense:', error);
        showToast('Error updating expense: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Open category modal
function openCategoryModal() {
    document.getElementById('categoryModal').style.display = 'flex';
    document.getElementById('categoryName').focus();
}

// Close category modal
function closeCategoryModal() {
    document.getElementById('categoryModal').style.display = 'none';
    document.getElementById('categoryForm').reset();
}

// Edit expense
function editExpense(expenseId) {
    const expense = expenses.find(e => e.id === expenseId);
    if (!expense) return;
    
    currentEditingExpenseId = expenseId;
    
    document.getElementById('editExpenseId').value = expense.id;
    document.getElementById('editDescription').value = expense.description;
    document.getElementById('editAmount').value = expense.amount;
    document.getElementById('editDate').value = expense.date;
    document.getElementById('editCategory').value = expense.category ? expense.category.id : '';
    
    document.getElementById('editExpenseModal').style.display = 'flex';
}

// Close edit modal
function closeEditModal() {
    document.getElementById('editExpenseModal').style.display = 'none';
    document.getElementById('editExpenseForm').reset();
    currentEditingExpenseId = null;
}

// Delete expense
async function deleteExpense(expenseId) {
    if (!confirm('Are you sure you want to delete this expense?')) {
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${API_BASE_URL}/expenses/${expenseId}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) {
            throw new Error('Failed to delete expense');
        }
        
        showToast('Expense deleted successfully!');
        await loadExpenses();
        
    } catch (error) {
        console.error('Error deleting expense:', error);
        showToast('Error deleting expense: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Delete category
async function deleteCategory(categoryId) {
    if (!confirm('Are you sure you want to delete this category? This action cannot be undone.')) {
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${API_BASE_URL}/categories/${categoryId}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) {
            throw new Error('Failed to delete category');
        }
        
        showToast('Category deleted successfully!');
        await loadCategories();
        await loadExpenses();
        
    } catch (error) {
        console.error('Error deleting category:', error);
        showToast('Error deleting category: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Filter expenses
function filterExpenses() {
    displayExpenses();
}

// Format date for display
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}