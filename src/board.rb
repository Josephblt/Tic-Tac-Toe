# frozen_string_literal: true

# Represents a tic-tac-toe board
class Board
  attr_reader :cells, :player1_symbol, :player2_symbol

  def initialize(player1_symbol, player2_symbol)
    @cells = Array.new(3) { Array.new(3) { Symbol::EMPTY } }
    @player1_symbol = player1_symbol
    @player2_symbol = player2_symbol
  end

  def convert_player1(cell)
    @cells[cell.column][cell.line] = @player1_symbol
  end

  def convert_player2(cell)
    @cells[cell.column][cell.line] = @player2_symbol
  end

  def convert_empty(cell)
    @cells[cell.column][cell.line] = Symbol::EMPTY
  end

  def available_cells
    empty_cells = []
    (0..2).each do |x|
      (0..2).each do |y|
        cell = Cell.new(x, y)
        empty_cells.push(cell) if empty? cell
      end
    end
    empty_cells
  end

  def empty?(cell)
    @cells[cell.column][cell.line] == Symbol::EMPTY
  end

  def full?
    (0..2).each do |x|
      (0..2).each do |y|
        return false if empty? Cell.new x, y
      end
    end
    true
  end

  def game_over?
    win_player1? || win_player2? || full?
  end

  def win_player1?
    win_player?(@player1_symbol)
  end

  def win_player2?
    win_player?(@player2_symbol)
  end

  private

  def win_column?(symbol, column)
    @cells[column][0] == symbol && @cells[column][1] == symbol && @cells[column][2] == symbol
  end

  def win_diagonal?(symbol)
    (@cells[0][0] == symbol && @cells[1][1] == symbol && @cells[2][2] == symbol) ||
      (@cells[2][0] == symbol && @cells[1][1] == symbol && @cells[0][2] == symbol)
  end

  def win_line?(symbol, line)
    @cells[0][line] == symbol && @cells[1][line] == symbol && @cells[2][line] == symbol
  end

  def win_player?(symbol)
    (0..2).each do |i|
      return true if win_column? symbol, i
      return true if win_line? symbol, i
      return true if win_diagonal? symbol
    end
    false
  end
end

# Helper class to define a board cell.
class Cell
  attr_reader :column, :line

  def initialize(column, line)
    @column = column
    @line = line
  end
end
