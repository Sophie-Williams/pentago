module Pentago
  class Game
    include Observable
    include Pentago::Rules

    def initialize(player1, player2, board=Board.new)
      @player1        = player1
      @player2        = player2
      @board          = board
      @player         = nil
      @winner         = nil
    end

    attr_reader :player1, :player2, :board

    def play
      while !@board.game_over?
        @player = who_plays?
        @player.play_turn(@board)

        changed
        notify_observers @player, @board
      end
      @winner = @player unless tie_game?
    end

    def turns
      return @board.moves if @board
      0
    end

    def player_at_turn
      @player
    end

    def winner
      @winner
    end

    def who_plays?
      players.next
    end

    private

    def players
      @players ||= [player1, player2].cycle
    end
  end
end

