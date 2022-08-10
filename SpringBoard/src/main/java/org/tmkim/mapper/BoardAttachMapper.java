package org.tmkim.mapper;

import org.tmkim.domain.BoardAttachVO;

import java.util.List;

public interface BoardAttachMapper
{
    public void insert(BoardAttachVO vo);
    public void delete(String uuid);
    public List<BoardAttachVO> findByBno(Long bno);
    public void deleteAll(Long bno);
}
