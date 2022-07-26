package org.tmkim.controller;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.tmkim.domain.Criteria;
import org.tmkim.domain.ReplyPageDTO;
import org.tmkim.domain.ReplyVO;
import org.tmkim.service.ReplyService;

@RequestMapping("/replies/")
@RestController
@Log4j2
@AllArgsConstructor
public class ReplyController
{
    private ReplyService service;

    // consumes과 produces를 이용해 JSON 방식의 데이터만 처리
    @PostMapping(value = "/new", consumes = "application/json", produces = {MediaType.TEXT_PLAIN_VALUE})
    public ResponseEntity<String> create(@RequestBody ReplyVO vo)
    {
        log.info("ReplyVO : " + vo);
        int insertCount = service.register(vo);
        log.info("Reply INSERT COUNT : " + insertCount);
        return insertCount == 1
                ? new ResponseEntity<>("success", HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);

    }

    @GetMapping(value = "/pages/{bno}/{page}", produces = {MediaType.APPLICATION_XML_VALUE, MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<ReplyPageDTO> getList(@PathVariable("page") int page, @PathVariable("bno") Long bno)
    {
        Criteria cri = new Criteria(page, 10);
        log.info("get Reply List bno: " + bno);
        log.info("cri : " + cri);

        return new ResponseEntity<>(service.getListPage(cri, bno), HttpStatus.OK);
    }

    @GetMapping(value = "/{rno}", produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
    public ResponseEntity<ReplyVO> get(@PathVariable("rno") Long rno)
    {
        log.info("get : " + rno);
        return new ResponseEntity<>(service.get(rno), HttpStatus.OK);
    }

    @DeleteMapping(value = "/{rno}", produces = {MediaType.TEXT_PLAIN_VALUE})
    public ResponseEntity<String> remove(@PathVariable("rno") Long rno)
    {
        log.info("remove : " + rno);
        return service.remove(rno) == 1
                ? new ResponseEntity<>("success", HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @RequestMapping(value = "/{rno}"
            , method = {RequestMethod.PUT, RequestMethod.PATCH}
            , consumes = "application/json"
            , produces = {MediaType.TEXT_PLAIN_VALUE})
    public ResponseEntity<String> modfiy(@RequestBody ReplyVO vo, @PathVariable("rno") Long rno)
    {
        vo.setRno(rno);
        log.info("rno : " + rno);
        log.info("modify : " + vo);

        return service.modify(vo) == 1
                ? new ResponseEntity<>("success", HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }


}
