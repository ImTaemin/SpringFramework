package org.tmkim.service;

import lombok.Setter;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.tmkim.domain.Criteria;
import org.tmkim.domain.ReplyPageDTO;
import org.tmkim.domain.ReplyVO;
import org.tmkim.mapper.BoardMapper;
import org.tmkim.mapper.ReplyMapper;

import java.util.List;

@Service
@Log4j2
public class ReplyServiceImpl implements ReplyService
{
    @Setter(onMethod_ = {@Autowired})
    private ReplyMapper replyMapper;

    @Setter(onMethod_ = {@Autowired})
    private BoardMapper boardMapper;

    @Transactional
    @Override
    public int register(ReplyVO vo)
    {
        log.info("register......." + vo);
        boardMapper.updateReplyCnt(vo.getBno(), 1);
        return replyMapper.insert(vo);
    }

    @Override
    public ReplyVO get(Long rno)
    {
        log.info("get........." + rno);
        return replyMapper.read(rno);
    }

    @Override
    public int modify(ReplyVO vo)
    {
        log.info("modify.........." + vo);
        return replyMapper.update(vo);
    }

    @Transactional
    @Override
    public int remove(Long rno)
    {
        log.info("remove......" + rno);

        ReplyVO vo = replyMapper.read(rno);
        boardMapper.updateReplyCnt(vo.getBno(), -1);
        return replyMapper.delete(rno);
    }

    @Override
    public List<ReplyVO> getList(Criteria cri, Long bno)
    {
        log.info("get Reply List of a Board " + bno );
        return replyMapper.getListWithPaging(cri, bno);
    }

    @Override
    public ReplyPageDTO getListPage(Criteria cri, Long bno)
    {
        return new ReplyPageDTO(replyMapper.getCountByBno(bno), replyMapper.getListWithPaging(cri, bno));
    }
}
