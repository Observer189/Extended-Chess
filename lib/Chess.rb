require 'singleton'
require_relative 'Board'
require_relative 'Move'
require_relative 'Piece'
require_relative 'piece_description'
require_relative 'setup'
require_relative 'Mode'
require_relative 'spawner'
require_relative 'Helpers/notation_translation_helper'

class Chess
  include Singleton
  attr_reader :boards, :movement_rules, :pieces, :modes, :setups
    def initialize
      @boards = Hash.new
      @boards['Square4x4'] = Board.new(Array.new(4){Array.new(4){0}})
      @boards['Square8x8'] = Board.new(Array.new(8){Array.new(8){0}})
      ffa = [
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [ 0,  0,  0,  0, 0,0,0,0,0,0,0,0, 0,  0,  0,  0],
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
        [nil,nil,nil,nil,0,0,0,0,0,0,0,0,nil,nil,nil,nil],
      ]
      @boards['FFA'] = Board.new(ffa)

      @movement_rules = Hash.new
      movement_rules['step_forward'] = method(:step_forward)
      movement_rules['step_forward_horse'] = method(:step_forward_horse)
      movement_rules['step_forward_bishop'] = method(:step_forward_bishop)
      movement_rules['step_forward_rook'] = method(:step_forward_rook)
      movement_rules['step_one_big_forward'] = method(:step_one_big_forward)
      movement_rules['step_straight_line'] = method(:step_straight_line)
      movement_rules['step_staight_and_castling'] = method(:step_staight_and_castling)
      movement_rules['step_diagonal_line'] = method(:step_diagonal_line)
      movement_rules['step_L'] = method(:step_L)
      movement_rules['step_any_dir_with_kill'] = method(:step_any_dir_with_kill)
      movement_rules['step_diagonal_right'] = method(:step_diagonal_right)
      movement_rules['step_diagonal_left'] = method(:step_diagonal_left)
      movement_rules['step_diagonal_right_with_killing'] = method(:step_diagonal_right_with_killing)
      movement_rules['step_diagonal_left_with_killing'] = method(:step_diagonal_left_with_killing)
      movement_rules['pawn_attack'] = method(:pawn_attack)
      movement_rules['diagonal_jump_with_kill'] = method(:diagonal_jump_with_kill)
      movement_rules['verhor_jump_with_kill'] = method(:verhor_jump_with_kill)
      movement_rules['step_any_dir'] = method(:step_any_dir)
      movement_rules['man_step'] = method(:man_step)


      @pieces = Hash.new
      @pieces['Pawn'] = PieceDescription.new("Pawn","","p",[movement_rules['step_forward'],movement_rules['step_one_big_forward'],
                                                            movement_rules['step_forward_horse'],movement_rules['step_forward_bishop'],movement_rules['step_forward_rook'],
                                                            movement_rules['pawn_attack']])
      @pieces['Rook'] = PieceDescription.new("Rook","r","r",[movement_rules['step_straight_line'],movement_rules['step_staight_and_castling']])
      @pieces['Bishop'] = PieceDescription.new("Bishop","b","b",[movement_rules['step_diagonal_line']])
      @pieces['Knight'] = PieceDescription.new("Knight","h","h",[movement_rules['step_L']])
      @pieces['King'] = PieceDescription.new("King","K","K",[movement_rules['step_any_dir_with_kill']])
      @pieces['Queen'] = PieceDescription.new("Queen","Q","Q",[movement_rules['step_straight_line'],movement_rules['step_diagonal_line']])
      @pieces['Man'] = PieceDescription.new("Man","m","m",
                                            [movement_rules['man_step'],
                                             movement_rules['diagonal_jump_with_kill']])
      @pieces['Dame'] = PieceDescription.new("Dame", "D", "D",
                                             [movement_rules['step_any_dir'],
                                              movement_rules['verhor_jump_with_kill'],
                                              movement_rules['diagonal_jump_with_kill']])


      @setups = Hash.new
      @setups['Classic'] = Setup.new('Classic',
        [
          %w[Rook Knight Bishop Queen !King Bishop Knight Rook],
          %w[Pawn Pawn Pawn Pawn Pawn Pawn Pawn Pawn]
        ]
      )
      @setups['Mongols'] = Setup.new('Classic',
                                     [
                                       %w[!Knight !Knight !Knight !Knight !Knight !Knight !Knight !Knight],
                                       %w[!Knight !Knight !Knight !Knight !Knight !Knight !Knight !Knight]
                                     ]
      )
      @setups['test1'] = Setup.new('test1',
        [[nil, nil, nil, nil],
                 [ nil,'!Man',nil ,nil]]
      )

      @setups['Checkers'] = Setup.new('Checkers',
        [
          ['Man', nil, 'Man', nil, 'Man', nil, 'Man', nil ],
          [ nil, 'Man', nil, 'Man', nil, 'Man', nil, 'Man'],
          ['Man', nil, 'Man', nil, 'Man', nil, 'Man', nil ]
        ]
      )
      @end_game_conditions = Hash.new
      @end_game_conditions['Piece_lost'] = method(:lost_all_pieces)
      @end_game_conditions['Chiefs_lost'] = method(:lost_all_chiefs)
      @end_game_conditions['All_opponents_lost'] = method(:all_opponents_lost)
      @end_game_conditions['All_opponents_won'] = method(:all_opponents_won)

      @possible_moves_postprocessors = Hash.new
      @possible_moves_postprocessors['Mandatory_killings'] = method(:mandatory_killings)

      @modes = Hash.new
      @modes['Classic'] = Mode.new(@boards['Square8x8'],
                                   [Spawner.new(Vector[0,0],Vector[1,0],Vector[0,1]),
                                    Spawner.new(Vector[7,0],Vector[-1,0],Vector[0,1])],
                                   2,2,['Classic','Mongols','Checkers'],
                                   [@end_game_conditions['Chiefs_lost']],
                                   [@end_game_conditions["All_opponents_lost"]])
      @modes['Giveaway'] = Mode.new(@boards['Square8x8'],
                                   [Spawner.new(Vector[0,0],Vector[1,0],Vector[0,1]),
                                    Spawner.new(Vector[7,0],Vector[-1,0],Vector[0,1])],
                                   2,2,['Classic'],
                                   [@end_game_conditions['All_opponents_won']],
                                    [@end_game_conditions['Piece_lost']],
                                    [@possible_moves_postprocessors['Mandatory_killings']])
      @modes['Checkers'] = Mode.new(@boards['Square8x8'],
                                   [Spawner.new(Vector[0,0],Vector[1,0],Vector[0,1]),
                                    Spawner.new(Vector[7,7],Vector[-1,0],Vector[0,-1])],
                                   2,2,['Checkers'],
                                    [@end_game_conditions['Piece_lost']],
                                    [@end_game_conditions["All_opponents_lost"]],
                                    [@possible_moves_postprocessors['Mandatory_killings']])
      @modes['Test'] = Mode.new(@boards['Square4x4'],
                                [Spawner.new(Vector[0,0],Vector[1,0],Vector[0,1]),
                                 Spawner.new(Vector[3,3],Vector[-1,0],Vector[0,-1])],
                                2,2,['test1'],
                                [@end_game_conditions['Chiefs_lost']],
                                [@end_game_conditions["All_opponents_lost"]],
                                [@possible_moves_postprocessors['Mandatory_killings']])
    end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Делает шаг вперед и становиться королевой
  def step_forward(piece, position)
    if(check_figure(piece.pos + piece.dir,position) != nil) then
      return []
    end
    movement = [[piece.pos,piece.pos + piece.dir]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    if(is_pos_on_finish_line(movement[0][1],piece.dir,position)) then
      removing = [piece.pos]
      spawning = [[movement[0][1],piece.team_color,piece.player_color,piece.dir,'Queen']]
      notation = NotationTranslationHelper.get_notation(piece,movement) + 'Q'
      return [Move.new(notation,nil,removing,spawning)]
    end
    return [Move.new(notation,movement)]
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Делает шаг вперед и становиться конем
  def step_forward_horse(piece, position)
    if(check_figure(piece.pos + piece.dir,position) != nil) then
      return []
    end
    movement = [[piece.pos,piece.pos + piece.dir]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    if(is_pos_on_finish_line(movement[0][1],piece.dir,position)) then
      removing = [piece.pos]
      spawning = [[movement[0][1],piece.team_color,piece.player_color,piece.dir,'Knight']]
      notation = NotationTranslationHelper.get_notation(piece,movement) + 'k'
      return [Move.new(notation,nil,removing,spawning)]
    end
    return []
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Делает шаг вперед и становиться ладьей
  def step_forward_rook(piece, position)
    if(check_figure(piece.pos + piece.dir,position) != nil) then
      return []
    end
    movement = [[piece.pos,piece.pos + piece.dir]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    if(is_pos_on_finish_line(movement[0][1],piece.dir,position)) then
      removing = [piece.pos]
      spawning = [[movement[0][1],piece.team_color,piece.player_color,piece.dir,'Rook']]
      notation = NotationTranslationHelper.get_notation(piece,movement) + 'r'
      return [Move.new(notation,nil,removing,spawning)]
    end
    return []
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Делает шаг вперед и становиться ферзем
  def step_forward_bishop(piece, position)
    if(check_figure(piece.pos + piece.dir,position) != nil) then
      return []
    end
    movement = [[piece.pos,piece.pos + piece.dir]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    if(is_pos_on_finish_line(movement[0][1],piece.dir,position)) then
      removing = [piece.pos]
      spawning = [[movement[0][1],piece.team_color,piece.player_color,piece.dir,'Bishop']]
      notation = NotationTranslationHelper.get_notation(piece,movement) + 'b'
      return [Move.new(notation,nil,removing,spawning)]
    end
    return []
  end

  def add_board(name,board)
    if(!@boards.has_key?(name) && !board.nil? && board.class == Board) then
      @boards[name] = board
    end
  end

  def add_movement_rule(name,method)
    if(!@movement_rules.has_key?(name) && !method.nil?) then
      @movement_rules[name] = method
    end
  end

  def add_piece(name,piece)
    if(!@pieces.has_key?(name) && !piece.nil? && piece.class == PieceDescription) then
      @pieces[name] = piece
    end
  end

  def add_setup(name,setup)
    if(!@setups.has_key?(name) && !setup.nil? && setup.class == Setup) then
      @setups[name] = setup
    end
  end

  def add_mode(name,mode)
    if(!@modes.has_key?(name) && !mode.nil? && mode.class == Mode) then
      @modes[name] = mode
    end
  end
  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Делает 2 шага  вперед, если до этого не делал вообще шагов
  def step_one_big_forward(piece, position)
    if(check_figure(piece.pos + piece.dir, position) != nil && check_figure(piece.pos + piece.dir + piece.dir, position) != nil )
      return []
    end
    if(piece.data[:Count_of_move] != 0)
      return []
    end
    movement = [[piece.pos,piece.pos + piece.dir * 2]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    return [Move.new(notation,movement)]
  end
  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Рокировка
  def step_staight_and_castling(piece, position)
    moves = []
    distances = [Vector[0,1],Vector[1,0],Vector[0,-1],Vector[-1,0]]
    if(piece.data[:Count_of_move] != 0)
      return []
    end
    distances.each do |direction|
      pos = piece.pos + direction
      while(pos[0].abs < 100 && pos[1].abs < 100)  #Ограничение в 100 выставленно, т.к. доски могут быть больше стандартного размера
        figure = check_figure(pos,position)
        if(!is_on_board?(pos,position) || figure.class == Piece) then
          if(figure.class == Piece && position.board.matrix[figure.pos[0]][figure.pos[1]].piece_description.name == 'King' && position.board.matrix[figure.pos[0]][figure.pos[1]].data[:Count_of_move] == 0 ) then
            notation = '0-0'
            if((piece.pos - figure.pos).magnitude > 3.1 )
              notation = '0-0-0'
            end
            move = Move.new(notation,[[piece.pos,pos - direction],[pos,pos - direction * 2]],nil)
            moves.push(move)
          end
          break
        end
        pos = pos + direction
      end
    end
    return moves
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  def step_diagonal_right(piece, position)
    right_dir = piece.dir.cross + piece.dir
    if(!is_on_board?(piece.pos + right_dir,position) || check_figure(piece.pos + right_dir,position) != nil) then
      return []
    end

    movement = [[piece.pos,piece.pos + right_dir]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    return [Move.new(notation,movement)]

  end

  def step_diagonal_right_with_killing(piece, position)
    right_dir = piece.dir.cross + piece.dir
    pos = piece.pos + right_dir
    if(!is_on_board?(piece.pos + right_dir,position)) then
      return []
    end

    f = check_figure(pos,position)
    if(f != nil && f.team_color != piece.team_color) then
      movement = [[piece.pos,pos]]
      removing = [pos]
      notation = NotationTranslationHelper.get_notation(piece,movement)
      return [Move.new(notation,movement,removing)]
    else
      return step_diagonal_right(piece,position)
    end
  end
  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  def step_diagonal_left(piece, position)
    left_dir = -piece.dir.cross + piece.dir
    if(!is_on_board?(piece.pos + left_dir,position) || check_figure(piece.pos + left_dir,position) != nil) then
      return []
    end

    movement = [[piece.pos,piece.pos + left_dir]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    return [Move.new(notation,movement)]

  end

  def step_diagonal_left_with_killing(piece, position)
    left_dir = -piece.dir.cross + piece.dir
    pos = piece.pos + left_dir
    if(!is_on_board?(pos,position)) then
      return []
    end

    f = check_figure(pos,position)
    if(f != nil && f.team_color != piece.team_color) then
      movement = [[piece.pos,pos]]
      removing = [pos]
      notation = NotationTranslationHelper.get_notation(piece,movement)
      return [Move.new(notation,movement,removing)]
    else
      return step_diagonal_right(piece,position)
    end
  end

  def pawn_attack(piece,position)
    right_dir = piece.dir.cross + piece.dir
    left_dir = -piece.dir.cross + piece.dir

    if(is_pos_on_finish_line(piece.pos + piece.dir,piece.dir,position)) then
      moves = []
      [piece.pos + right_dir,piece.pos + left_dir].each do |pos|
        figure = check_figure(pos,position)
        if(figure.class == Piece && figure.team_color != piece.team_color) then
          ['Queen', 'Rook', 'Bishop', 'Knight'].each do |p|
            removing = [piece.pos]
            spawning = [[pos,piece.team_color,piece.player_color,piece.dir,p]]
            notation = NotationTranslationHelper.get_notation(piece,[[piece.pos,pos]]) + @pieces[p].char_name
            m = Move.new(notation,nil,removing,spawning)
            moves.push(m)
          end
        end
      end
      return moves
    else
      return step_diagonal_right_with_killing(piece,position) + step_diagonal_left_with_killing(piece,position)
    end
  end
  #piece - Piece
  #positiong - Position
  #TODO Пояснения как ходит
  def man_step(piece,position)
    moves = step_diagonal_left(piece,position) + step_diagonal_right(piece,position)
    moves.each_index do |ind|
      #Если мы походили на последнюю линию, то надо поставить дамку
      if(is_pos_on_finish_line(moves[ind].movements[0][1],piece.dir,position)) then
        removing = [piece.pos]
        spawning = [[moves[ind].movements[0][1],piece.team_color,piece.player_color,piece.dir,'Dame']]
        notation = NotationTranslationHelper.get_notation(piece,movement)
        moves[ind] = Move.new(notation,nil,removing,spawning)
      end
    end
    return moves
  end


  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  def diagonal_jump_with_kill(piece,position)
    moves = []
    forward = piece.dir
    right_dir = piece.dir.cross
    ([1,-1].product [1,-1] ).to_a.each do |p|
      near = piece.pos + p[0] * right_dir + p[1] * forward
      far = piece.pos + p[0] * 2 * right_dir + p[1] * 2 * forward
      p = check_figure(near,position)
      if(p != nil && is_on_board?(near,position) && is_on_board?(far,position) &&
      p.team_color != piece.team_color && check_figure(far,position).nil?) then
        movement = [[piece.pos,far]]
        removing = [near]
        notation = NotationTranslationHelper.get_notation(piece,movement)
        move = Move.new(notation,movement,removing)
        moves.push(move)
      end
    end
    return moves
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #TODO Пояснения как ходит
  def verhor_jump_with_kill(piece,position)
    moves = []
    forward = piece.dir
    right_dir = piece.dir.cross
    [[1,0],[-1,0],[0,1],[0,-1]].each do |p|
      near = piece.pos + p[0]*right_dir + p[1]*forward
      far = piece.pos+p[0]*2*right_dir + p[1]*2*forward
      p = check_figure(near,position)
      if(p != nil && is_on_board?(near,position) && is_on_board?(far,position) &&
        p.team_color != piece.team_color && check_figure(far,position).nil?) then
        movement = [[piece.pos,far]]
        removing = [near]
        notation = NotationTranslationHelper.get_notation(piece,movement)
        move = Move.new(notation,movement,removing)
        moves.push(move)
      end
    end
    return moves
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #TODO Пояснения как ходит
  def step_any_dir(piece,position)
    moves = []
    right_dir = piece.dir.cross
    var = ([0,1,-1].product [0,1,-1] ).to_a
    var.delete([0,0])
    var.each do |v|
      pos = piece.pos + piece.dir * v[0] + right_dir*v[1]
      if(is_on_board?(pos,position) || check_figure(pos,position) == nil) then
        movement = [[piece.pos,pos]]
        notation = NotationTranslationHelper.get_notation(piece,movement)
        move = Move.new(notation,movement,nil)
        moves.push(move)
      end
    end
    return moves
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Ходит по прямой, как ладья
  def step_straight_line(piece, position)
    moves = []
    distances = [Vector[0,1],Vector[1,0],Vector[0,-1],Vector[-1,0]]
    distances.each do |direction|
      pos = piece.pos + direction
      while(pos[0].abs < 100 && pos[1].abs < 100)  #Ограничение в 100 выставленно, т.к. доски могут быть больше стандартного размера
        figure = check_figure(pos,position)
        if(!is_on_board?(pos,position) || (figure.class == Piece && figure.team_color == piece.team_color))
          break
        end

        if(figure.class == Piece && figure.team_color != piece.team_color) then
          moves.push(give_move(figure,piece,pos))
          break
        end
        moves.push(give_move(figure,piece,pos))
        pos = pos + direction
      end
    end
    return moves
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Ходит на искосок, как слон
  def step_diagonal_line(piece, position)
    moves = []
    distances = [Vector[1,1],Vector[-1,1],Vector[1,-1],Vector[-1,-1]]
    distances.each do |direction|
      pos = piece.pos + direction
      while(pos[0].abs < 100 && pos[1].abs < 100)  #Ограничение в 100 выставленно, т.к. доски могут быть больше стандартного размера
        figure = check_figure(pos,position)
        if(!is_on_board?(pos,position) || (figure.class == Piece && figure.team_color == piece.team_color))
          break
        end
        if(figure.class == Piece && figure.team_color != piece.team_color) then
          moves.push(give_move(figure,piece,pos))
          break
        end
        moves.push(give_move(figure,piece,pos))
        pos = pos + direction
      end
    end
    return moves
  end
  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Ходит буквой Г или L если на англиский вариант
  def step_L(piece, position)
    moves = []
    distances = [Vector[1,2],Vector[2,1],Vector[-1,2],Vector[-2,1],Vector[1,-2],Vector[2,-1],Vector[-1,-2],Vector[-2,-1]]
    distances.each do |direction|
      pos = piece.pos + direction
      figure = check_figure(pos,position)
      if(!is_on_board?(pos,position) || (figure.class == Piece && figure.team_color == piece.team_color))
        next
      end
      moves.push(give_move(figure,piece,pos))
    end
    return moves
  end

  #piece - Piece
  #positiong - Position
  #return - Array[Move]
  #Ходит по всем клеткам в своем радиусе с возможностью убить, как король
  def step_any_dir_with_kill(piece,position)
    moves = []
    right_dir = piece.dir.cross
    var = ([0,1,-1].product [0,1,-1] ).to_a
    var.delete([0,0])
    var.each do |v|
      pos = piece.pos + piece.dir * v[0] + right_dir * v[1]
      figure = check_figure(pos,position)
      if(!is_on_board?(pos,position) || (figure.class == Piece && figure.team_color == piece.team_color))
        next
      end
      moves.push(give_move(figure,piece,pos))
    end
    return moves
  end

  #figure - Piece
  #piece - Piece
  #pos - Vector
  #return - Move
  #Вспомогательня ф-я для создания ф-й ходьбы
  def give_move(figure, piece, pos)
    movement = [[piece.pos,pos]]
    notation = NotationTranslationHelper.get_notation(piece,movement)
    removing = nil
    if (figure.class == Piece && figure.team_color != piece.team_color) then
      removing = [pos]
    end
    return Move.new(notation,movement,removing)
  end

  #pos - Vector
  #positiong - Position
  #return - ?
  def check_figure(pos, position)
    if (position.board.matrix[pos[0]] != nil &&
      position.board.matrix[pos[0]][pos[1]] != nil &&
      position.board.matrix[pos[0]][pos[1]] != 0) then
      return position.board.matrix[pos[0]][pos[1]]
    end
    return nil
  end

  def lost_all_pieces(player_color,position)
    c = 0

    position.board.matrix.each do |line|
      c+= line.count { |p| p.class == Piece && p.player_color == player_color}
    end
    if c == 0 then
      return 'Lost all pieces!'
    end
    return nil
  end

  def all_opponents_lost(player_color,position)
    if(position.losers.length == position.colors.length-1 && position.active_players.include?(player_color))  then
      return 'All opponents lost!'
      end
    return nil
  end

  def all_opponents_won(player_color,position)
    if(position.winners.length == position.colors.length-1 && position.active_players.include?(player_color)) then
      return 'All opponents won!'
    end
    return nil
  end
  def lost_all_chiefs(player_color,position)
    c = 0
    position.board.matrix.each do |line|
      c+= line.count { |p| p.class == Piece && p.player_color == player_color && p.is_chief}
    end
    if c == 0 then
      return 'Lost all chiefs!'
    end
    return nil
  end
  #постобработчик возможных ходов, который обязывает игрока делать взятие фигуры
  # если оно возможно
  def mandatory_killings(possible_moves)
    if possible_moves.values.count { |move| !move.removing.nil? && move.removing.length>0 } > 0  then
      possible_moves.delete_if { |key,value| value.removing.nil? || value.removing.length==0}
    end
  end
  
  #pos - Vector
  #positiong - Position  
  # Проверяет лежит ли заданная позиция в пределах игрового поля
  def is_on_board?(pos, position)
    return pos[0] < position.board.height && pos[0] >= 0 && pos[1] < position.board.width && pos[1] >= 0 &&
    position.board.matrix[pos[0]][pos[1]] != nil
  end
  #Функция определяет является ли заданая клетка
  # финишной для фигуры с данным направлением
  # Под финишными клетками подразумеваются те, в которых пешки превращаются в ферзей
  def is_pos_on_finish_line(pos, dir, position)
    return is_on_board?(pos,position) && !is_on_board?(pos+dir,position)
  end

end

