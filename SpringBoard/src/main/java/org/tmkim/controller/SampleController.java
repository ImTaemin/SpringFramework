package org.tmkim.controller;

import lombok.extern.log4j.Log4j2;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.tmkim.domain.SampleVO;
import org.tmkim.domain.Ticket;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@RequestMapping("/sample")
@RestController
@Log4j2
public class SampleController
{

    @GetMapping(value = "/getText", produces = "text/plain; charset=UTF-8")
    public String getText()
    {
        log.info("MIME TYPE : " + MediaType.TEXT_PLAIN_VALUE);
        return "This is sample";
    }

    @GetMapping(value = "/getSample", produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
    public SampleVO getSample()
    {
        return new SampleVO(112, "SAMPLE", "LOAD");
    }

    @GetMapping("/getList")
    public List<SampleVO> getList()
    {
        return IntStream.range(1,10)
                .mapToObj(i -> new SampleVO(i, i + "First", i +"Last"))
                .collect(Collectors.toList());
    }

    @GetMapping("/getMap")
    public Map<String, SampleVO> getMap()
    {
        Map<String, SampleVO> map = new HashMap<>();
        map.put("First", new SampleVO(111, "그루트", "주니어"));
        return map;
    }
    
    @GetMapping(value = "/check", params = {"height", "weight"})
    public ResponseEntity<SampleVO> check(Double height, Double weight)
    {
        SampleVO vo = new SampleVO(0, "" + height, "" + weight);

        ResponseEntity<SampleVO> result = null;

        if(height < 150)
        {
            result = ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(vo);
        }
        else
        {
            result = ResponseEntity.status(HttpStatus.OK).body(vo);
        }

        return result;
    }

    @GetMapping("/product/{cat}/{pid}")
    public String[] getPath(@PathVariable("cat") String cat, @PathVariable("pid") Integer pid)
    {
        return new String[] {"category : " + cat, "productid : " + pid};
    }

    @PostMapping("/ticket")
    public Ticket conver(@RequestBody Ticket ticket)
    {
        log.info("convert........ticket" + ticket);
        return ticket;
    }

    @GetMapping("/all")
    public void doAll()
    {
        log.info("do all can access everybody");
    }

    @GetMapping("/member")
    public void doMember()
    {
        log.info("logined member");
    }

    @GetMapping("/admin")
    public void doAdmin()
    {
        log.info("admin only");
    }

}
