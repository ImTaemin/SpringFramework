package org.tmkim.service;

import org.tmkim.domain.Criteria;
import org.tmkim.domain.ReplyPageDTO;
import org.tmkim.domain.ReplyVO;

import java.util.List;

public interface ReplyService
{
    public int register(ReplyVO vo);
    public ReplyVO get(Long rno);
    public int modify(ReplyVO reply);
    public int remove(Long rno);
    public List<ReplyVO> getList(Criteria cri, Long bno);
    public ReplyPageDTO getListPage(Criteria cri, Long bno);
}
