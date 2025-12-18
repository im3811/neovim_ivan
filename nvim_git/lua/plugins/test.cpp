#include <iostream>
#include <vector>
#include <string>

using namespace std;

// Function to calculate factorial
int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

// Function to find sum of vector
int sum_vector(const vector<int>& numbers) {
    int sum = 0;
    for (int num : numbers) {
        sum += num;
    }
    return sum;
}

// Class example
class Student {
private:
    string name;
    int age;
    vector<int> grades;

public:
    Student(string n, int a) : name(n), age(a) {}
    
    void addGrade(int grade) {
        grades.push_back(grade);
    }
    
    double getAverage() {
        if (grades.empty()) return 0.0;
        int total = 0;
        for (int grade : grades) {
            total += grade;
        }
        return static_cast<double>(total) / grades.size();
    }
    
    void printInfo() {
        cout << "Name: " << name << ", Age: " << age 
             << ", Average: " << getAverage() << endl;
    }
};

int main() {
    cout << "== C++ Debugger Demo ===" << endl;
    
    // 1. Simple factorial calculation
    int num = 5;
    int result = factorial(num);
    cout << "Factorial of " << num << " is: " << result << endl;
    
    // 2. Vector operations
    vector<int> numbers = {10, 20, 30, 40, 50};
    int total = sum_vector(numbers);
    cout << "Sum of vector: " << total << endl;
    
    // 3. Class/Object example
    Student student("Ivan", 21);
    student.addGrade(85);
    student.addGrade(92);
    student.addGrade(78);
    student.addGrade(95);
    student.printInfo();
    
    // 4. String operations
    string message = "Hello from C++!";
    cout << message << endl;
    cout << "Message length: " << message.length() << endl;
    
    return 0;
}
