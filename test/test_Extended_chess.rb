require_relative "test_helper"

class TestExtendedChess < MiniTest::Test

  def setup
      @chess = Chess.new
      @mode_classic_chess = @chess.modes['Classic']
      @mode_checkers = @chess.modes['Checkers']
      @player1 = Player.new('Alex',:red)
      @player2 = Player.new('Max',:blue)
   end

  def test_setup
    assert_equal 'Alex', @player1.name
    assert_equal 'Max', @player2.name
    assert_equal color = :red, @player1.color
    assert_equal color = :blue, @player2.color
  end

  def test_step_forward_chess
    game = @mode_classic_chess.make_game([@player1, @player2], [@chess.setups['Classic'], @chess.setups['Classic']])

    matrix_chess = [
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil],
        [ 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'],
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil],
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil],
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil],
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil],
        [ 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'],
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil],
    ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '1'
    game.step!('a2-a3') # Ход верхнего игрока
    assert_equal false, equal_matrix?(game.position.board.matrix, matrix_chess), '2'

    matrix_chess = [
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 1
        [    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 2
        [ 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 3
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 4
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 5
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 6
        [ 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 7
        [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 8
      ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '3'

    game.step!('b7-b6') # Ход нижнего игрока
    game.step!('b2-b3') # Ход верхнего игрока
    game.step!('b6-b5') # Ход нижнего игрока
    game.step!('b3-b4') # Ход верхнего игрока

    matrix_chess = [
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 1
      [    nil,    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 2
      [ 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 3
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 4
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 5
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 6
      [ 'Pawn',    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 7
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 8
    ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '4'

  end

  def test_sequence_move_chess
    game = @mode_classic_chess.make_game([@player1, @player2], [@chess.setups['Classic'], @chess.setups['Classic']])

    game.step!('a2-a3') # Ход верхнего игрока
    game.step!('b7-b6') # Ход нижнего игрока
    game.step!('b2-b3') # Ход верхнего игрока
    game.step!('b6-b5') # Ход нижнего игрока
    game.step!('b3-b4') # Ход верхнего игрока

    matrix_chess = [
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 1
      [    nil,    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 2
      [ 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 3
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 4
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 5
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 6
      [ 'Pawn',    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 7
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 8
    ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '1'

    game.step!('b5-b4') # Ход нижнего игрока не сделан, так как место b4 занято

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '2'

    # Право хода сохраняется за нижним игроком после невыполненного хода
    game.step!('c7-c6') # Ход нижнего игрока
    matrix_chess = [
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 1
      [    nil,    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 2
      [ 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 3
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 4
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 5
      [    nil,    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil], # 6
      [ 'Pawn',    nil,    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 7
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 8
    ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '3'

    game.step!('c6-c5') # Ход нижнего игрока
    # Доска не изменилась, потому что игроку нельзя сделать правильный ход два раза подряд
    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '4'

    # Проверка на то, что право хода у другого игрока
    game.step!('c2-c3') # Ход верхнего игрока
    matrix_chess = [
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 1
      [    nil,    nil,   nil , 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 2
      [ 'Pawn',    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil], # 3
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 4
      [    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil,    nil], # 5
      [    nil,    nil, 'Pawn',    nil,    nil,    nil,    nil,    nil], # 6
      [ 'Pawn',    nil,    nil, 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'], # 7
      [    nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil], # 8
    ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_chess), '5'
  end

  #TODO: Сделать свою доску и добавить ход с убийством фишки от другого игрока
  def test_diagonal_jump_with_kill_checkers
    game = @chess.modes['Test'].make_game([@player1,@player2],[@chess.setups['test1'],@chess.setups['test1']])

    matrix_checkers = [
      [ nil,   nil,    nil,   nil], # 1
      [ nil, 'Man',    nil,   nil], # 2
      [ nil,   nil,  'Man',   nil], # 3
      [ nil,   nil,    nil,   nil], # 4
    ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_checkers), '1'

   game.step!('mb2-d4')

    matrix_checkers = [
      [ nil,   nil,    nil,     nil], # 1
      [ nil,   nil,    nil,     nil], # 2
      [ nil,   nil,    nil,     nil], # 3
      [ nil,   nil,    nil,   'Man'], # 4
    ]

    assert_equal true, equal_matrix?(game.position.board.matrix, matrix_checkers), '2'

  end

  #TODO: Сделать свою доску и удостовериться, что последний ход другого игрока так же заканчивает игру
   def test_is_ended?
     game = @chess.modes['Test'].make_game([@player1,@player2],[@chess.setups['test1'],@chess.setups['test1']])
     assert_equal false, game.is_ended?, '1'
     game.step!('mb2-d4')
     assert_equal true, game.is_ended?, '2'
   end

  #TODO: Сделать свою доску и удостовериться в правильном выводе, когда побеждает другой игрок
   def test_get_result
     game = @chess.modes['Test'].make_game([@player1,@player2],[@chess.setups['test1'],@chess.setups['test1']])
     assert_nil game.get_result, '1' # Тест проходит, если @game.get_result  nil
     game.step!('mb2-d4')
     refute_nil game.get_result, '2' # Тест проходит, если @game.get_result  не nil

     assert_equal game.position.winners, [[:red,"All opponents lost!"]], '3'
     assert_equal game.position.losers,  [[:blue, "Lost all pieces!"]], '4'
   end
end
