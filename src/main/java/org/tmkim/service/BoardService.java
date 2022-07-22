package org.tmkim.service;

import java.util.List;

import org.tmkim.domain.BoardVO;

public interface BoardService {

	public void register(BoardVO board);
	public BoardVO get(Long bno);
	public boolean modify(BoardVO board);
	public boolean remove(Long bno);
	public List<BoardVO> getList();
}
