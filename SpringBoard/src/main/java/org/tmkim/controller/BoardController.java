package org.tmkim.controller;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.tmkim.domain.BoardAttachVO;
import org.tmkim.domain.BoardVO;
import org.tmkim.domain.Criteria;
import org.tmkim.domain.PageDTO;
import org.tmkim.service.BoardService;

import java.util.List;

@Log4j2
@Controller
@RequestMapping("/board/*")
@AllArgsConstructor
public class BoardController
{
    private BoardService service;

//    @GetMapping("/list")
//    public void list(Model model)
//    {
//        log.info("list");
//        model.addAttribute("list", service.getList());
//    }

    @GetMapping("/list")
    public void list(Criteria cri, Model model)
    {
        log.info("list" + cri);
        model.addAttribute("list", service.getList(cri));
//        model.addAttribute("pageMaker", new PageDTO(cri, 123));

        int total = service.getTotal(cri);
        log.info("total : " + total);

        model.addAttribute("pageMaker", new PageDTO(cri, total));
    }

    @GetMapping("/register")
    public void register()
    {

    }

    @PostMapping("/register")
    public String register(BoardVO board, RedirectAttributes rttr)
    {
        log.info("register : " + board);
        if(board.getAttachList() != null)
        {
            board.getAttachList().forEach(attach -> log.info(attach));
        }

        service.register(board);
        rttr.addFlashAttribute("result", board.getBno());
        return "redirect:/board/list";
    }

    @GetMapping({"/get", "/modify"})
    public void get(@RequestParam("bno") Long bno, @ModelAttribute("cri") Criteria cri, Model model)
    {
        log.info("/get or /modify");
        model.addAttribute("board", service.get(bno));
    }

    @PostMapping("/modify")
    public String modify(BoardVO board, @ModelAttribute("cri") Criteria cri, RedirectAttributes rttr)
    {
        log.info("modify : " + board);

        if (service.modify(board))
        {
            rttr.addFlashAttribute("result", "success");
        }

        // UriComponentsBuilder 사용x
//        rttr.addAttribute("pageNum", cri.getPageNum());
//        rttr.addAttribute("amount", cri.getAmount());
//        rttr.addAttribute("type", cri.getType());
//        rttr.addAttribute("keyword", cri.getKeyword());
//        return "redirect:/board/list";

        // UriComponentsBuilder 사용
        return "redirect:/board/list" + cri.getListLink();
    }

    @PostMapping("/remove")
    public String remove(@RequestParam("bno") Long bno, @ModelAttribute("cri") Criteria cri, RedirectAttributes rttr)
    {
        log.info("remove...... " + bno);

        if (service.remove(bno))
        {
            rttr.addFlashAttribute("result", "success");
        }

//        rttr.addAttribute("pageNum", cri.getPageNum());
//        rttr.addAttribute("amount", cri.getAmount());
//        rttr.addAttribute("type", cri.getType());
//        rttr.addAttribute("keyword", cri.getKeyword());

        return "redirect:/board/list" + cri.getListLink();
    }

    @GetMapping(value = "/getAttachList", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<List<BoardAttachVO>> getAttachList(Long bno)
    {
        log.info("getAttachList " + bno);
        return new ResponseEntity<>(service.getAttachList(bno), HttpStatus.OK);
    }
}
