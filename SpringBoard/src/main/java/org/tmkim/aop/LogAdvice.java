package org.tmkim.aop;

import lombok.extern.log4j.Log4j2;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Aspect
@Log4j2
@Component
public class LogAdvice
{
    // service패키지 안의 모든 접근제한자와 SampleService로 시작하는 모든 메서드(인자 상관x)
    @Before("execution(* org.tmkim.service.SampleService.*(..))")
    public void logBefore(){
        log.info("=========================");
    }

    @Before("execution(* org.tmkim.service.SampleService.doAdd(String, String)) && args(str1, str2)")
    public void logBeforeWithParam(String str1, String str2)
    {
        log.info("str1: " + str1);
        log.info("str2: " + str2);
    }

    @AfterThrowing(pointcut = "execution(* org.tmkim.service.SampleService.*(..))", throwing = "exception")
    public void logException(Exception exception)
    {
        log.info("Exception....!!!!");
        log.info("exception: " + exception);
    }

    @Around("execution(* org.tmkim.service.SampleService.*(..))")
    public Object logTime(ProceedingJoinPoint pjp)
    {
        long start = System.currentTimeMillis();

        log.info("Target: " + pjp.getTarget());
        log.info("Param: " + Arrays.toString(pjp.getArgs()));

        //invoke method
        Object result = null;
        try
        {
            result = pjp.proceed();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
        long end = System.currentTimeMillis();

        log.info("TIME: " + (end - start));
        return result;
    }
}


