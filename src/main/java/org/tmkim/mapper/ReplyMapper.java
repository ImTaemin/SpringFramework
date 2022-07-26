package org.tmkim.mapper;

import org.apache.ibatis.annotations.Param;
import org.tmkim.domain.Criteria;
import org.tmkim.domain.ReplyVO;

import java.util.List;

public interface ReplyMapper
{
    public int insert(ReplyVO vo);
    public ReplyVO read(Long rno);
    public int delete(Long rno);
    public int update(ReplyVO reply);
    public List<ReplyVO> getListWithPaging(@Param("cri")Criteria cri, @Param("bno") Long bno);
    public int getCountByBno(Long bno);
}
