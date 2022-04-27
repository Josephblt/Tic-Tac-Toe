# frozen_string_literal: true

require 'rspec'
require './src/board'
require './src/symbol'

describe Board do
  describe 'initialize' do
    it 'Initialization NOUGHT CROSS' do
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS
      board = Board.new symbol1, symbol2

      (0..2).each do |x|
        (0..2).each do |y|
          expect(board.cells[x][y]).to eq(Symbol::EMPTY)
        end
      end

      expect(board.player1_symbol).to eq(symbol1)
      expect(board.player2_symbol).to eq(symbol2)
    end

    it 'Initialization CROSS NOUGHT' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT
      board = Board.new symbol1, symbol2

      (0..2).each do |x|
        (0..2).each do |y|
          expect(board.cells[x][y]).to eq(Symbol::EMPTY)
        end
      end

      expect(board.player1_symbol).to eq(symbol1)
      expect(board.player2_symbol).to eq(symbol2)
    end
  end

  describe 'convert_player1' do
    it 'Valid Cells' do
      column = 2
      line = 1
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.convert_player1 Cell.new column, line

      expect(board.cells[column][line]).to eq(symbol1)
    end

    it 'Invalid Cells' do
      column = 3
      line = 3
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2

      expect { board.convert_player1(Cell.new(column, line)) }.to raise_error(NoMethodError)
    end
  end

  describe 'convert_player2' do
    it 'Valid Cells' do
      column = 2
      line = 1
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.convert_player2 Cell.new column, line

      expect(board.cells[column][line]).to eq(symbol2)
    end

    it 'Invalid Cells' do
      column = 3
      line = 3
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2

      expect { board.convert_player2(Cell.new(column, line)) }.to raise_error(NoMethodError)
    end
  end

  describe 'convert_empty' do
    it 'Valid Cells' do
      column = 0
      line = 2
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      (0..2).each do |x|
        (0..2).each do |y|
          board.cells[x][y] = Symbol::CROSS
        end
      end
      board.convert_empty Cell.new column, line

      expect(board.cells[column][line]).to eq(Symbol::EMPTY)
    end

    it 'Invalid Cells' do
      column = -1
      line = 3
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      (0..2).each do |x|
        (0..2).each do |y|
          board.cells[x][y] = Symbol::CROSS
        end
      end
      board.convert_empty Cell.new column, line

      expect(board.cells[column][line]).to eq(Symbol::EMPTY)
    end
  end

  describe 'available_cell' do
    it 'Random Cells' do
      cell1 = Cell.new 0, 0
      cell2 = Cell.new 1, 1
      cell3 = Cell.new 1, 2
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.cells[cell1.column][cell1.line] = Symbol::CROSS
      board.cells[cell2.column][cell2.line] = Symbol::CROSS
      board.cells[cell3.column][cell3.line] = Symbol::CROSS
      available_cells = board.available_cells

      expect(available_cells.size).to eq(6)
      expect(available_cells).to_not contain_exactly([cell1, cell2, cell3])
    end
  end

  describe 'empty?' do
    it 'Symbol::NOUGHT' do
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.cells[0][0] = Symbol::NOUGHT

      expect(board.empty?(Cell.new(0, 0))).to be_falsey
    end

    it 'Symbol::CROSS' do
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.cells[0][0] = Symbol::CROSS

      expect(board.empty?(Cell.new(0, 0))).to be_falsey
    end

    it 'Symbol::EMPTY' do
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.cells[0][0] = Symbol::EMPTY

      expect(board.empty?(Cell.new(0, 0))).to be_truthy
    end
  end

  describe 'full?' do
    it 'NOUGHT CROSS' do
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.cells[0][0] = Symbol::CROSS
      board.cells[0][1] = Symbol::NOUGHT
      board.cells[0][2] = Symbol::CROSS
      board.cells[1][0] = Symbol::NOUGHT
      board.cells[1][1] = Symbol::CROSS
      board.cells[1][2] = Symbol::NOUGHT
      board.cells[2][0] = Symbol::CROSS
      board.cells[2][1] = Symbol::NOUGHT
      board.cells[2][2] = Symbol::CROSS

      expect(board.full?).to be_truthy
    end

    it 'NOUGHT CROSS EMPTY' do
      symbol1 = Symbol::NOUGHT
      symbol2 = Symbol::CROSS

      board = Board.new symbol1, symbol2
      board.cells[0][0] = Symbol::CROSS
      board.cells[0][1] = Symbol::NOUGHT
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = Symbol::NOUGHT
      board.cells[1][1] = Symbol::CROSS
      board.cells[1][2] = Symbol::NOUGHT
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::NOUGHT
      board.cells[2][2] = Symbol::CROSS

      expect(board.full?).to be_falsey
    end
  end

  describe 'game_over??' do
    it 'Player 1 Win Not Full' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol1
      board.cells[1][0] = symbol2
      board.cells[1][1] = symbol2
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.game_over?).to be_truthy
    end

    it 'Player 1 Win Full' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol1
      board.cells[1][0] = symbol2
      board.cells[1][1] = symbol2
      board.cells[1][2] = symbol1
      board.cells[2][0] = symbol2
      board.cells[2][1] = symbol2
      board.cells[2][2] = symbol1

      expect(board.game_over?).to be_truthy
    end

    it 'Player 1 Win Not Full' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol1
      board.cells[1][0] = symbol2
      board.cells[1][1] = symbol2
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.game_over?).to be_truthy
    end

    it 'Player 2 Win Full' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = symbol2
      board.cells[1][0] = symbol1
      board.cells[1][1] = symbol1
      board.cells[1][2] = symbol2
      board.cells[2][0] = symbol1
      board.cells[2][1] = symbol1
      board.cells[2][2] = symbol2

      expect(board.game_over?).to be_truthy
    end

    it 'Player 2 Win Not Full' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = symbol2
      board.cells[1][0] = symbol1
      board.cells[1][1] = symbol1
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.game_over?).to be_truthy
    end

    it 'Draw Full' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol2
      board.cells[1][0] = symbol2
      board.cells[1][1] = symbol1
      board.cells[1][2] = symbol2
      board.cells[2][0] = symbol2
      board.cells[2][1] = symbol2
      board.cells[2][2] = symbol1

      expect(board.game_over?).to be_truthy
    end

    it 'Not over' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol2
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = Symbol::EMPTY
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.game_over?).to be_falsey
    end
  end

  describe 'win_player1?' do
    it 'First Line Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol1
      board.cells[1][0] = symbol2
      board.cells[1][1] = symbol2
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player1?).to be_truthy
    end

    it 'Second Line Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = Symbol::EMPTY
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol1
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player1?).to be_truthy
    end

    it 'Third Line Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = Symbol::EMPTY
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol1
      board.cells[2][1] = symbol1
      board.cells[2][2] = symbol1

      expect(board.win_player1?).to be_truthy
    end

    it 'First Column Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol2
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = symbol1
      board.cells[1][1] = symbol2
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol1
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player1?).to be_truthy
    end

    it 'Second Column Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol2
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = symbol1
      board.cells[1][1] = symbol2
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol1
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player1?).to be_truthy
    end

    it 'Third Column Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = symbol1
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = Symbol::EMPTY
      board.cells[1][2] = symbol1
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = symbol1

      expect(board.win_player1?).to be_truthy
    end

    it 'Diagonal 1 Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol2
      board.cells[0][2] = symbol2
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = symbol1
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = symbol1

      expect(board.win_player1?).to be_truthy
    end

    it 'Diagonal 2 Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = symbol1
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = symbol1
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol1
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player1?).to be_truthy
    end
  end

  describe 'win_player2?' do
    it 'First Line Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = symbol2
      board.cells[1][0] = symbol1
      board.cells[1][1] = symbol1
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player2?).to be_truthy
    end

    it 'Second Line Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = Symbol::EMPTY
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol2
      board.cells[0][2] = symbol2
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player2?).to be_truthy
    end

    it 'Third Line Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = Symbol::EMPTY
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol2
      board.cells[2][1] = symbol2
      board.cells[2][2] = symbol2

      expect(board.win_player2?).to be_truthy
    end

    it 'First Column Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol1
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = symbol2
      board.cells[1][1] = symbol1
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol2
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player2?).to be_truthy
    end

    it 'Second Column Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol1
      board.cells[0][2] = Symbol::EMPTY
      board.cells[1][0] = symbol2
      board.cells[1][1] = symbol1
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol2
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player2?).to be_truthy
    end

    it 'Third Column Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol2
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = Symbol::EMPTY
      board.cells[1][2] = symbol2
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = symbol2

      expect(board.win_player2?).to be_truthy
    end

    it 'Diagonal 1 Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol2
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol1
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = symbol2
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = Symbol::EMPTY
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = symbol2

      expect(board.win_player2?).to be_truthy
    end

    it 'Diagonal 2 Win' do
      symbol1 = Symbol::CROSS
      symbol2 = Symbol::NOUGHT

      board = Board.new symbol1, symbol2
      board.cells[0][0] = symbol1
      board.cells[0][1] = symbol1
      board.cells[0][2] = symbol2
      board.cells[1][0] = Symbol::EMPTY
      board.cells[1][1] = symbol2
      board.cells[1][2] = Symbol::EMPTY
      board.cells[2][0] = symbol2
      board.cells[2][1] = Symbol::EMPTY
      board.cells[2][2] = Symbol::EMPTY

      expect(board.win_player2?).to be_truthy
    end
  end
end

describe Cell do
  describe 'initialize' do
    it 'Initialization NOUGHT CROSS' do
      column = 2
      line = 1
      cell = Cell.new column, line

      expect(cell.column).to eq(column)
      expect(cell.line).to eq(line)
    end
  end
end
