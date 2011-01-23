require 'spec_helper'

module Pentago
  describe Board do
    describe '#initialize' do
      it 'should create an empty board' do
        board = Board.new
        board.squares.should == Array.new(Board::SIZE, nil)
      end

      it 'should create a board based on a previous state' do
        # from array
        previous = Array.new(Board::SIZE, nil)
        6.times do |n|
          pos = rand(Board::SIZE+1)
          pos = rand(Board::SIZE+1) while previous[pos]
          previous[pos] = 1 # at this point we don't mind about players
        end

        board = Board.new(previous)
        board.squares.should == previous

        # from another board
        board2 = Board.new(board)
        board2.squares.should == board.squares
      end
      
      it 'should raise TypeError if bad previous state' do
        previous = Hash.new
        expect {
          board = Board.new(previous)
        }.to raise_error(TypeError)
      end
    end
    
    describe 'instance methods' do
      before(:each) do
        state = Array.new(Board::SIZE, nil)
        state[7] = :white
        state[14] = :white
        state[10] = :black
        state[22] = :black
        @board = Board.new(state)
      end
      
      describe '#[]' do
        it 'should let us get marble in position' do
          @board[1,1].should == :white
          @board[2,2].should == :white
          @board[4,1].should == :black
          @board[4,3].should == :black
          @board[3,5].should be_nil
        end
        
        it 'should raise IllegalPosition if accessing out of bounds' do
          expect {
            m = @board[7,3]
          }.to raise_error(Pentago::Board::IllegalPositionError)
        end
      end
      
      describe '#[]=' do
        it 'should set a marble in position' do
          @board[4,5] = :white
          @board[4,5].should == :white
          @board[4,2] = :black
          @board[4,2].should == :black
        end
        
        it 'should raise IllegalPosition if accessing out of bounds' do
          expect {
            @board[6,2] = :black
          }.to raise_error(Pentago::Board::IllegalPositionError)
        end
        
        it 'should raise IllegalPostionError if setting an occupied cell' do
          expect {
            @board[2,2] = :black
          }.to raise_error(Pentago::Board::IllegalPositionError)
        end
      end

      describe '#rotate' do
        before(:each) do
          @board = Board.new
        end

        it 'should raise InvalidSquareError if invalid square' do
          expect {
            @board.rotate(7, :clockwise)
          }.to raise_error(Pentago::Board::InvalidSquareError)
        end

        it 'should raise InvalidDirectionError if invalid direction' do
          expect {
            @board.rotate(0, :foowise)
          }.to raise_error(Pentago::Board::InvalidDirectionError)
        end

        it 'should allow us to rotate a square CW/CCW' do
          @board[0,0] = 1
          @board.rotate(0, :clockwise)
          @board[2,0].should == 1

          @board.rotate(0, :counter_clockwise)
          @board[0,0].should == 1
        end

        it 'rotating CW should not affect neighbour squares' do
          @board[0,0] = 1
          @board.rotate(0, :clockwise)
          @board[3,1] = 2
          @board.rotate(1, :clockwise)
          @board[2,0].should == 1 && @board[4,0].should == 2
        end
      end
    end
  end
end

