# encoding: utf-8
module BoardHelper

  def norloge(board, box)
    format = :norloge2
    format = :norloge if board.object_type == Board.free
    format = :norloge if box
    board.created_at.to_s format
  end

end
