package org.tmkim.controller;

import lombok.extern.log4j.Log4j2;
import net.coobird.thumbnailator.Thumbnailator;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.tmkim.domain.AttachFileDTO;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.*;

@Log4j2
@Controller
public class UploadController
{
    @GetMapping("/uploadForm")
    public void uploadForm()
    {
        log.info("upload form");
    }

    @PostMapping("uploadFormAction")
    public void uploadFormPost(MultipartFile[] uploadFile, Model model)
    {
        String uploadFolder = "C:\\upload";

        for (MultipartFile multipartFile : uploadFile)
        {
            log.info("---------------------------");
            log.info("Upload File Name : " + multipartFile.getOriginalFilename());
            log.info("Upload File Size : " + multipartFile.getSize());

            File saveFile = new File(uploadFolder, multipartFile.getOriginalFilename());

            try
            {
                multipartFile.transferTo(saveFile);
            }
            catch (Exception e)
            {
                log.error(e.getMessage());
            }
        }
    }

    @GetMapping("/uploadAjax")
    public void uploadAajx()
    {
        log.info("upload ajax");
    }

    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    @PostMapping(value = "uploadAjaxAction", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<AttachFileDTO>> uploadAjaxPost(MultipartFile[] uploadFile)
    {
        List<AttachFileDTO> list = new ArrayList<>();
        String uploadFolder = "C:\\upload";

        // 폴더 생성
        String uploadFolderPath = getFolder();
        File uploadPath = new File(uploadFolder, uploadFolderPath);
        log.info("upload path : " + uploadPath);
        // yyyy/MM/dd 형식의 폴더 생성
        if (uploadPath.exists() == false)
        {
            uploadPath.mkdirs();
        }

        for (MultipartFile multipartFile : uploadFile)
        {
            AttachFileDTO attachDTO = new AttachFileDTO();
            String uploadFileName = multipartFile.getOriginalFilename();

            // IE는 파일 경로를 가지고 옴
            uploadFileName = uploadFileName.substring(uploadFileName.lastIndexOf("\\") + 1);
            log.info("only file name : " + uploadFileName);
            attachDTO.setFileName(uploadFileName);

            UUID uuid = UUID.randomUUID();
            uploadFileName = uuid.toString() + "_" + uploadFileName;

            try
            {
                File saveFile = new File(uploadPath, uploadFileName);
                multipartFile.transferTo(saveFile);

                attachDTO.setUuid(uuid.toString());
                attachDTO.setUploadPath(uploadFolderPath);

                //이미지 타입 확인
                if (checkImageType(saveFile))
                {
                    attachDTO.setImage(true);
                    FileOutputStream thumbnail = new FileOutputStream(new File(uploadPath, "s_" + uploadFileName));
                    Thumbnailator.createThumbnail(multipartFile.getInputStream(), thumbnail, 100, 100);
                    thumbnail.close();
                }

                list.add(attachDTO);
            }
            catch (Exception e)
            {
                log.error(e.getMessage());
            }
        }
        return new ResponseEntity<>(list, HttpStatus.OK);
    }

    @GetMapping("/display")
    @ResponseBody
    public ResponseEntity<byte[]> getFile(String fileName)
    {
        log.info("fileName : " + fileName);
        File file = new File("c:\\upload\\" + fileName);
        log.info("file : " + file);

        ResponseEntity<byte[]> result = null;

        try
        {
            HttpHeaders header = new HttpHeaders();
            header.add("Content-Type", Files.probeContentType(file.toPath()));
            result = new ResponseEntity<>(FileCopyUtils.copyToByteArray(file), header, HttpStatus.OK);
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        return result;
    }

    @GetMapping(value = "/download", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    @ResponseBody
    public ResponseEntity<Resource> downloadFile(@RequestHeader("User-Agent") String userAgent, String fileName)
    {
        Resource resource = new FileSystemResource("c:\\upload\\" + fileName);
        if (resource.exists() == false)
        {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        String resourceName = resource.getFilename();

        // UUID 제거
        String resourceOriginalName = resourceName.substring(resourceName.indexOf("_") + 1);

        HttpHeaders headers = new HttpHeaders();
        try
        {
            String downloadName = null;
            if (userAgent.contains("Trident"))
            {
                log.info("IE browser");
                downloadName = URLEncoder.encode(resourceName, "UTF-8").replaceAll("\\+", " ");
            }
            else if (userAgent.contains("Edge"))
            {
                log.info("Edge browser");
                downloadName = URLEncoder.encode(resourceName, "UTF-8");
            }
            else
            {
                log.info("Chrome browser");
                downloadName = new String(resourceName.getBytes("UTF-8"), "ISO-8859-1");
            }

            log.info("downloadName : " + downloadName);

            headers.add("Content-Disposition"
                    , "attachment; filename=" + downloadName);
        }
        catch (UnsupportedEncodingException e)
        {
            e.printStackTrace();
        }

        return new ResponseEntity<Resource>(resource, headers, HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping(value = "/deleteFile", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<String> deleteFile(@RequestBody HashMap<String, Object> map)
    {
        log.info("deleteFile : " + map.get("fileName"));
        File file;

        try
        {
            // 일반 파일 삭제
            file = new File("c:\\upload\\" + URLDecoder.decode((String) map.get("fileName"), "UTF-8"));
            file.delete();

            if (map.get("type").equals("image"))
            {
                // 원본 이미지 파일 삭제
                String largeFileName = file.getAbsolutePath().replace("s_", "");
                log.info("largeFileName : " + largeFileName);

                file = new File(largeFileName);
                file.delete();
            }
        }
        catch (UnsupportedEncodingException e)
        {
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<String>("deleted", HttpStatus.OK);
    }

    private String getFolder()
    {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        String str = sdf.format(date);
        return str.replace("-", File.separator);
    }

    private boolean checkImageType(File file)
    {
        try
        {
            String contentType = Files.probeContentType(file.toPath());
            return contentType.startsWith("image");
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        return false;
    }
}
