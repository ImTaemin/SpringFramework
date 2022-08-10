package org.tmkim.service;

import java.util.List;

import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.tmkim.domain.BoardAttachVO;
import org.tmkim.domain.BoardVO;
import org.tmkim.domain.Criteria;
import org.tmkim.mapper.BoardAttachMapper;
import org.tmkim.mapper.BoardMapper;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j2;

@Log4j2
@Service
public class BoardServiceImpl implements BoardService
{
    @Setter(onMethod_ = @Autowired)
    private BoardMapper mapper;

    @Setter(onMethod_ = @Autowired)
    private BoardAttachMapper attachMapper;

    @Transactional
    @Override
    public void register(BoardVO board)
    {
        log.info("register............." + board);

        mapper.insertSelectKey(board);

        if(board.getAttachList() == null || board.getAttachList().size() <= 0)
        {
            return;
        }

        board.getAttachList().forEach(attach ->{
            attach.setBno(board.getBno());
            attachMapper.insert(attach);
        });
    }

    @Override
    public BoardVO get(Long bno)
    {
        log.info("get............." + bno);
        return mapper.read(bno);
    }

    @Transactional
    @Override
    public boolean modify(BoardVO board)
    {
        log.info("modify..........." + board);

        //일단 삭제하고 다시 추가하는 방식
        attachMapper.deleteAll(board.getBno());
        boolean modifyResult = mapper.update(board) == 1;

        if(modifyResult && board.getAttachList() != null && board.getAttachList().size() > 0)
        {
            board.getAttachList().forEach(attach -> {
                attach.setBno(board.getBno());
                attachMapper.insert(attach);
            });
        }

        return modifyResult;
    }

    @Override
    public boolean remove(Long bno)
    {
        log.info("remove..........." + bno);
        attachMapper.deleteAll(bno);
        mapper.deleteReply(bno);
        return mapper.delete(bno) == 1;
    }

    //	@Override
//	public List<BoardVO> getList() {
//		log.info("getList..................");
//		return mapper.getList();
//	}

    @Override
    public List<BoardVO> getList(Criteria cri)
    {
        log.info("get List with criteria : " + cri);
        return mapper.getListWithPaging(cri);
    }

    @Override
    public int getTotal(Criteria cri)
    {
        log.info("get total count");
        return mapper.getTotalCount(cri);
    }

    @Override
    public List<BoardAttachVO> getAttachList(Long bno)
    {
        log.info("get Attach list by bno" + bno);
        return attachMapper.findByBno(bno);
    }
}
