module Pentago
  class Board
    IllegalPositionError  = Class.new(StandardError)
    InvalidSquareError    = Class.new(StandardError)
    InvalidDirectionError = Class.new(StandardError)

    ROTATION_MATRICES = {
      :clockwise          => [2,7,12,-5,0,5,-12,-7,-2],
      :counter_clockwise  => [12,5,-2,7,0,-7,2,-5,-12]
    }

    ROTATION_DIRECTIONS = ROTATION_MATRICES.keys

    SQUARES = [
      [ 0, 1, 2, 6, 7, 8,12,13,14],
	    [ 3, 4, 5, 9,10,11,15,16,17],
	    [18,19,20,24,25,26,30,31,32],
	    [21,22,23,27,28,29,33,34,35]
    ]

    ROWS = COLS = 6
    SIZE = ROWS * COLS

    attr_accessor :squares

    include Pentago::Rules

    class << self
      def restore(board)
        restored = Board.new
        restored.squares = case board
        when Array
          raise TypeError, "incompatible board array #{board.size}" if board.size != SIZE
          board.dup
        when Board
          board.dup.to_a
        else
          raise TypeError, 'incompatible types'
        end

        restored
      end
    end

    def initialize
      clear
    end

    def [](x, y)
      raise IllegalPositionError, "illegal position [#{x}, #{y}]" unless valid_position?(x, y)
      @squares[translate(x, y)]
    end

    def []=(x, y, marble)
      raise IllegalPositionError, 'already occupied position' if self[x, y]
      @squares[translate(x, y)] = marble
    end

    def rows
      @squares.each_slice(ROWS).to_a
    end

    def columns
      rows.transpose
    end

    # TODO: add an algorithm to retrieve diagonals of a generic NxN board
    def diagonals
      diagonals = []

      # center diagonals
      diagonals << Array.new(ROWS) { |r| self[r, r] }
      diagonals << Array.new(ROWS) { |r| self[ROWS-r-1, r] }

      # off-center diagonals
      diagonals << Array.new(ROWS-1) { |r| self[r,r+1] }
      diagonals << Array.new(ROWS-1) { |r| self[r+1,r] }
      diagonals << Array.new(ROWS-1) { |r| self[r,ROWS-r-2] }
      diagonals << Array.new(ROWS-1) { |r| self[r+1,ROWS-r-1] }
    end

    def rotate(square, direction = :clockwise)
      raise InvalidSquareError, 'invalid square' unless SQUARES[square]
      raise InvalidDirectionError, 'unrecognized rotation direction' \
        unless ROTATION_DIRECTIONS.include?(direction)

      rotated_squares = @squares.dup

      itx = (0..8).to_a
      itx.reverse! if direction == :counter_clockwise
      itx.each do |p|
        position  = SQUARES[square][p]
        marble    = @squares[position]
        rotated_squares[position + ROTATION_MATRICES[direction][p]] = marble
      end

      @squares = rotated_squares
    end

    def empty_squares
      @squares.map.with_index { |sq, index| index unless sq }.compact
    end

    def empty_positions
      empty_squares.map { |sq| [sq%COLS, sq/ROWS] }
    end

    def moves
      @squares.compact.size
    end

    def full?
      moves == SIZE
    end

    def clear
      @squares = Array.new(SIZE, nil)
    end

    def to_s
      output = "   0  1  2 | 3  4  5 \n"
      output << "  ---------+---------\n"
      output << rows.map.with_index do |row, i|
        row_output = i == 3 ? "  ---------+---------\n#{i}|" : "#{i}|"
        row_output << row.map.with_index do |value, j|
          cell_output = j == 3 ? '|' : ''
          cell_output << (value ? " #{value} " : ' . ')
        end.join
      end.join("\n")
    end

    alias_method :to_str, :to_s

    def to_a
      @squares
    end

    def ==(other)
      @squares == other.squares
    end

    alias_method :eql?, :==

    def dup
      Board.restore(@squares)
    end

    private

    def translate(x,y)
      x + ROWS*y
    end

    def valid_position?(x, y)
      x >= 0 && x < COLS && y >= 0 && y < ROWS
    end
  end
end
