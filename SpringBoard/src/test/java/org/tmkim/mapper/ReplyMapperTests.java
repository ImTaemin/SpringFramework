package org.tmkim.mapper;

import lombok.Setter;
import lombok.extern.log4j.Log4j2;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.tmkim.domain.Criteria;
import org.tmkim.domain.ReplyVO;

import java.util.List;
import java.util.stream.IntStream;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/spring/root-context.xml")
@Log4j2
public class ReplyMapperTests
{
    private Long[] bnoArr = {50L, 48L, 47L, 46L, 45L, 44L, 43L, 42L, 41L};

    @Setter(onMethod_ = {@Autowired})
    private ReplyMapper mapper;

    @Test
    public void testMapper()
    {
        log.info(mapper);
    }

    @Test
    public void testCreate()
    {
        IntStream.rangeClosed(1, 10).forEach(i -> {
            ReplyVO vo = new ReplyVO();

            vo.setBno(bnoArr[i % 5]);
            vo.setReply("댓글 테스트" + i);
            vo.setReplyer("replyer" + i);

            mapper.insert(vo);
        });
    }

    @Test
    public void testRead()
    {
        Long targetRno = 5L;
        ReplyVO vo = mapper.read(targetRno);
        log.info(vo);
    }

    @Test
    public void testDelete()
    {
        Long targetRno = 1L;
        mapper.delete(targetRno);
    }

    @Test
    public void testUpdate()
    {
        Long targetRno = 10L;
        ReplyVO vo = mapper.read(targetRno);
        vo.setReply("Update Reply");
        int count = mapper.update(vo);
        log.info("UPDATE COUNT : " + count);
    }

    @Test
    public void testList()
    {
        Criteria cri = new Criteria();
        List<ReplyVO> replies = mapper.getListWithPaging(cri, bnoArr[0]);
        replies.forEach(reply -> log.info(reply));
    }

    @Test
    public void testList2()
    {
        Criteria cri = new Criteria(2, 10);
        List<ReplyVO> replies = mapper.getListWithPaging(cri, 48L);
        replies.forEach(reply -> log.info(reply));
    }
}