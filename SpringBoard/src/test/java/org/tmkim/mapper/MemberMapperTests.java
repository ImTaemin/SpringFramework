package org.tmkim.mapper;

import lombok.Setter;
import lombok.extern.log4j.Log4j2;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;
import org.tmkim.domain.MemberVO;

@Log4j2
@RunWith(SpringRunner.class)
@ContextConfiguration({"classpath:WEB-INF/spring/*.xml"})
public class MemberMapperTests
{
    @Setter(onMethod_ = @Autowired)
    private MemberMapper mapper;

    @Test
    public void testRead()
    {
        MemberVO vo = mapper.read("admin95");
        log.info(vo);
        vo.getAuthList().forEach(authVO -> log.info(authVO));
    }
}
