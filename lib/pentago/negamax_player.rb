module Pentago
  class NegamaxPlayer < Player
    def initialize(opts={})
      super(opts)

      @search_depth = opts.fetch(:search_depth, 1)
    end

    attr_accessor :search_depth

    def compute_next_move
      available_moves(@board).sort_by do |square, rotation|
        x, y = square
        s, d = rotation

        board_copy = @board.dup
        board_copy[x, y] = @marble
        board_copy.rotate(s, d)

        negamax(board_copy, @search_depth, opponent(@marble))
      end.first.flatten
    end

    def negamax(board, depth, player, alpha=-1, beta=1)
      return score(board, player) if depth == 0 || board.game_over?

      available_moves(board).each do |square, rotation|
        x, y = square
        s, d = rotation

        board_copy = board.dup
        board_copy[x,y] = player
        board_copy.rotate(s, d)

        alpha = [alpha, -negamax(board_copy, depth-1, opponent(player), -beta, -alpha)].max
        return beta if alpha >= beta
      end

      alpha
    end

    # TODO: improve scoring functions
    def score(board, player)
      winner = board.find_winner
      return 1000000 if winner && winner == player
      return -1000000 if winner && winner == opponent(player)
      score_for(board, player) - score_for(board, opponent(player))
    end

    def score_for(board, marble)
      board.runs.inject(0) do |sum, run|
        sum + run.count { |value| value.nil? || value == marble }
      end
    end

    def opponent(player)
      (player == 1) ? 2 : 1
    end

    def available_moves(board)
      board.empty_positions.product(
        (0...Board::SQUARES.size).to_a.product(Board::ROTATION_DIRECTIONS)
      )
    end
  end
end
