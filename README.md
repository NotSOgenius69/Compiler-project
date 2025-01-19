# Bongo++ Compiler

Bongo++ is a custom programming language designed to simplify programming concepts while introducing a syntax inspired by the Bengali language. This repository contains the lexer and parser implementation for Bongo++, providing functionality for processing and executing programs written in this language.

## Features

### Supported Constructs
- **Data Types**:
  - `purno`: Integer
  - `dosomik`: Float/Decimal
  - `sobdo`: String

- **Control Flow Statements**:
  - Conditional statements: `hoyKi` (if), `nahoyKi` (else if), `nahole` (else)
  - Loops: `jotokkhon` (while), `ChalayDen` (for)
  - Switch-case: `kono` (switch), `khetre` (case), `thaman` (break)

- **Operators**:
  - Arithmetic: `jog` (add), `biyog` (subtract), `gun` (multiply), `vaag` (divide)
  - Logical: `ebong` (AND), `othoba` (OR)
  - Comparison: `boro` (greater than), `choto` (less than), `soman` (equal to)

- **Other Keywords**:
  - `dhoren`: Variable declaration
  - `ferot`: Return
  - `dekhao`: Print/output

### Functions
- User-defined functions with parameter passing and return values.
- Example syntax for defining a function:
  ```
  purno baksho myFunction(purno a, purno b) {
      hoyKi (a boro b) {
          ferot a biyog b;
      }
      nahole {
          ferot b biyog a;
      }
  }
  ```

### Input/Output
- Print values or messages using `dekhao`.
- Example:
  ```
  dekhao "Hello, Bongo++!";
  dekhao x jog y;
  ```

## Getting Started

### Prerequisites
- Install a C compiler such as GCC.
- Install Flex and Bison for lexing and parsing.

### Building the Compiler
1. Clone this repository:
   ```
   git clone https://github.com/NotSOgenius69/Compiler-project.git
   cd Compiler-project
   ```
2. Build the project using the following commands:
   ```
   flex bongo.l
   bison -d bongo.y
   gcc -o bongo lex.yy.c parser.tab.c -lfl
   ```

### Running a Program
1. Create a Bongo++ source file (e.g., `program.bpp`) with your code.
2. Execute the following command to run the program:
   ```
   ./bongo input.txt output.txt
   ```

## Example Program
```
// Function definition
purno baksho addNumbers(purno a, purno b) {
    ferot a jog b;
}

purno baksho shuru() {
    dhoren purno x;
    x = 10;
    dhoren purno y;
    y = 20;

    dekhao "The sum is:";
    dekhao addNumbers(x, y);

    ferot 0;
}
```

### Output
```
The sum is:
30
```

## Future Improvements
- Adding support for advanced data structures like arrays and objects.
- Enhancing error handling for better debugging.
- Expanding the standard library with more built-in functions.

## Contributions
Contributions are welcome! If you'd like to improve this project, feel free to fork the repository and submit a pull request. Please ensure your changes are well-documented.

---

Enjoy programming in Bongo++!

